############################################################
# 01_fit_tasks.R  (VERSIONE CORRETTA E ROBUSTA)
#
# - Fit continuous norming per ciascun subtest con GAMLSS (BB)
# - Modella mu(age) e sigma(age) per ridurre drift residuo con l'età
# - Rende i modelli predicibili dopo readRDS() senza hack globali:
#     fit$call$data <- tmp
############################################################

rm(list = ls())

# --- Pacchetti ---
pkgs <- c("gamlss","gamlss.dist","dplyr","readr","tibble")
stopifnot(all(sapply(pkgs, requireNamespace, quietly = TRUE)))
library(gamlss)
library(gamlss.dist)
library(dplyr)
library(readr)
library(tibble)

source("R/spec/load_spec.R")
bii_spec <- read_bii_spec()

DATA_PATH <- "norms_BII/standardization_sample_raw.csv"
OUT_DIR   <- "norms_BII"
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# ============================================================
# 0) DATI
# ============================================================
dd <- readr::read_csv(DATA_PATH, show_col_types = FALSE)

if (!("age_y" %in% names(dd))) stop("Colonna 'age_y' non trovata.")
dd <- dd %>%
  mutate(
    age_y = as.numeric(age_y),
    age_m = as.integer(round(age_y * 12))
  )

# Controllo minimo età
if (any(!is.finite(dd$age_y))) stop("Ci sono valori non finiti in age_y.")
if (min(dd$age_y, na.rm = TRUE) <= 0) stop("age_y contiene valori <= 0, controlla il dataset.")

# --- Range didattici per CL/SS ---

tasks_spec <- spec_subtest_table(bii_spec) %>%
  transmute(
    task = id,
    raw_col = paste0(task, "_grezzo"),
    minScore = raw_min,
    maxScore = raw_max
  )

missing_cols <- tasks_spec$raw_col[!tasks_spec$raw_col %in% names(dd)]
if (length(missing_cols) > 0) stop("Mancano colonne: ", paste(missing_cols, collapse=", "))

# ============================================================
# 1) FIT PER TASK
# ============================================================

fit_task_norm <- function(df, raw_col, minScore, maxScore) {
  
  bd <- maxScore - minScore
  if (bd <= 0) stop("Range non valido per ", raw_col)
  
  tmp <- df %>%
    transmute(
      age_y = age_y,
      score_raw = .data[[raw_col]]
    ) %>%
    mutate(
      score_shift = score_raw - minScore
    ) %>%
    # rimuovi NA (fondamentale per evitare fit/predizioni bizzarre)
    filter(is.finite(age_y), !is.na(score_shift))
  
  if (nrow(tmp) < 50) stop(raw_col, ": troppo pochi casi validi dopo filtraggio NA (", nrow(tmp), ").")
  
  # check range teorico
  if (any(tmp$score_shift < 0 | tmp$score_shift > bd, na.rm = TRUE)) {
    bad_n <- sum(tmp$score_shift < 0 | tmp$score_shift > bd, na.rm = TRUE)
    bad_ex <- tmp %>%
      filter(score_shift < 0 | score_shift > bd) %>%
      head(10)
    stop(
      raw_col, ": ", bad_n, " valori fuori range teorico.\n",
      "Esempi (prime 10 righe):\n",
      paste(capture.output(print(bad_ex)), collapse = "\n")
    )
  }
  
  # Fit: mu(age) e sigma(age)
  # pbm(mono="up") = effetto monotono crescente dell'età
  fit <- gamlss(
    formula  = cbind(score_shift, bd - score_shift) ~ pbm(age_y, mono = "up"),
    sigma.fo = ~ pb(age_y),
    family   = BB,
    data     = tmp,
    trace    = FALSE
  )
  
  # IMPORTANTISSIMO: rendi il modello auto-consistente per la predizione dopo readRDS()
  # In questo modo predictAll() non fallisce cercando 'tmp' in giro.
  fit$call$data <- tmp
  list(
    fit = fit,
    bd = bd,
    minScore = minScore,
    maxScore = maxScore,
    n_used = nrow(tmp),
    age_range = range(tmp$age_y, na.rm = TRUE)
  )
}

fits <- vector("list", length = nrow(tasks_spec))
names(fits) <- tasks_spec$task

for (i in seq_len(nrow(tasks_spec))) {
  tk <- tasks_spec$task[i]
  cat("Fit:", tk, "\n")
  
  fits[[tk]] <- fit_task_norm(
    df = dd,
    raw_col = tasks_spec$raw_col[i],
    minScore = tasks_spec$minScore[i],
    maxScore = tasks_spec$maxScore[i]
  )
}

# ============================================================
# 2) SALVATAGGIO
# ============================================================
out_path <- file.path(OUT_DIR, "fits_BII.rds")
saveRDS(list(fits = fits, tasks_spec = tasks_spec), out_path)

cat("\nOK: salvato ", out_path, "\n", sep = "")
cat("N usati per task (dopo rimozione NA):\n")
print(sapply(fits, function(x) x$n_used))
