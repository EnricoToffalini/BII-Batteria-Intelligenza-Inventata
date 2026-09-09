############################################################
# 02_tasks_tables_and_PP.R  (CONTINUOUS NORMING + WECHSLER-CENTERING)
#
# - Continuous norming: GAMLSS (BB) su age_y in continuo (fit nel file 1)
# - Tabelle: riportate per bande d'età usando age_ref_y (centro banda)
# - Wechsler-style: centratura normativa per task x age_band sul campione
#   (mean=10; opzionale SD=3)
#
# OUTPUT
# - tasks_conversion_tables_grezzo_to_PP_by_ageband_PRELIM.csv
# - standardization_sample_scored_PP_PRELIM.csv
# - tasks_conversion_tables_grezzo_to_PP_by_ageband_OFFICIAL.csv
# - standardization_sample_scored_PP_OFFICIAL.csv
############################################################

rm(list = ls())

# ============================================================
# 0) Pacchetti
# ============================================================
pkgs <- c("gamlss","gamlss.dist","dplyr","tidyr","readr","tibble","stringr")
stopifnot(all(sapply(pkgs, requireNamespace, quietly = TRUE)))
library(gamlss)
library(gamlss.dist)
library(dplyr)
library(tidyr)
library(readr)
library(tibble)
library(stringr)

# ============================================================
# 1) Path + opzioni
# ============================================================
DATA_PATH <- "norms_BII/standardization_sample_raw.csv"
OUT_DIR   <- "norms_BII"

TARGET_MEAN_PP <- 10
TARGET_SD_PP   <- 3

FORCE_SD <- TRUE

# Forza monotonicità grezzo->PP dentro ogni task x age_band
ENFORCE_MONOTONE <- TRUE

# ============================================================
# 2) Carica fit
# ============================================================
obj_path <- file.path(OUT_DIR, "fits_BII.rds")
if (!file.exists(obj_path)) stop("File non trovato: ", obj_path, "\nEsegui prima 01_fit_tasks.R")

obj <- readRDS(obj_path)
if (!all(c("fits","tasks_spec") %in% names(obj))) {
  stop("Struttura inattesa in fits_BII.rds. Attesi: fits, tasks_spec. Trovati: ", paste(names(obj), collapse=", "))
}

fits <- obj$fits
tasks_spec <- obj$tasks_spec
stopifnot(is.list(fits), length(fits) > 0)

# ============================================================
# 3) Leggi dati
# ============================================================
dd <- readr::read_csv(DATA_PATH, show_col_types = FALSE) %>%
  mutate(
    age_y = as.numeric(age_y),
    age_m = as.integer(round(age_y * 12))
  )

missing_cols <- tasks_spec$raw_col[!tasks_spec$raw_col %in% names(dd)]
if (length(missing_cols) > 0) stop("Mancano colonne nel CSV: ", paste(missing_cols, collapse=", "))

# ============================================================
# 4) Bande d'età + assegnazione deterministica + label + chiavi sorting
# ============================================================
make_age_bands <- function(min_age_m, max_age_m) {
  min_age_m <- max(min_age_m, 72)
  bands <- list()
  
  # <10 anni: 4 mesi (72-119)
  lower_4 <- seq(72, min(119, max_age_m), by = 4)
  for (lo in lower_4) bands[[length(bands) + 1]] <- c(lo, min(lo + 3, max_age_m))
  
  # 10-15;11: 6 mesi (120-191)
  if (max_age_m >= 120) {
    lower_6 <- seq(120, min(191, max_age_m), by = 6)
    for (lo in lower_6) bands[[length(bands) + 1]] <- c(lo, min(lo + 5, max_age_m))
  }
  
  # >=16: 12 mesi (>=192)
  if (max_age_m >= 192) {
    lower_12 <- seq(192, max_age_m, by = 12)
    for (lo in lower_12) bands[[length(bands) + 1]] <- c(lo, min(lo + 11, max_age_m))
  }
  
  bands_df <- do.call(rbind, bands) %>% as.data.frame()
  names(bands_df) <- c("age_lo_m","age_hi_m")
  
  bands_df %>%
    mutate(
      age_ref_m = round((age_lo_m + age_hi_m) / 2),
      age_ref_y = age_ref_m / 12,
      age_band = sprintf(
        "%d;%02d-%d;%02d",
        age_lo_m %/% 12, age_lo_m %% 12,
        age_hi_m %/% 12, age_hi_m %% 12
      )
    )
}

assign_age_band <- function(age_m) {
  if (is.na(age_m)) return(NA_character_)
  
  if (age_m < 120) {
    lo <- 72 + 4 * floor((age_m - 72) / 4); hi <- lo + 3
  } else if (age_m < 192) {
    lo <- 120 + 6 * floor((age_m - 120) / 6); hi <- lo + 5
  } else {
    lo <- 192 + 12 * floor((age_m - 192) / 12); hi <- lo + 11
  }
  
  sprintf("%d;%02d-%d;%02d", lo %/% 12, lo %% 12, hi %/% 12, hi %% 12)
}

age_band_to_label <- function(age_band) {
  # input "10;00-10;05" -> output "10anni;0mesi-10anni;5mesi"
  if (is.na(age_band)) return(NA_character_)
  
  parts <- strsplit(age_band, "-", fixed = TRUE)[[1]]
  a <- parts[1]; b <- parts[2]
  
  a2 <- strsplit(a, ";", fixed = TRUE)[[1]]
  b2 <- strsplit(b, ";", fixed = TRUE)[[1]]
  
  ya <- as.integer(a2[1]); ma <- as.integer(a2[2])
  yb <- as.integer(b2[1]); mb <- as.integer(b2[2])
  
  sprintf("%danni;%dmesi-%danni;%dmesi", ya, ma, yb, mb)
}

# costruisci age_bands dal range osservato
age_bands <- make_age_bands(min(dd$age_m, na.rm = TRUE), max(dd$age_m, na.rm = TRUE))

# dedup sempre (robusto) e crea label + chiavi sorting
dup_ab <- age_bands %>% count(age_band) %>% filter(n > 1)
if (nrow(dup_ab) > 0) {
  warning(
    "Trovate age_band duplicate in age_bands. Le sto deduplicando (tengo la prima occorrenza).\n",
    paste(capture.output(print(head(dup_ab, 50))), collapse = "\n")
  )
}
age_bands <- age_bands %>%
  distinct(age_band, .keep_all = TRUE) %>%
  mutate(age_band_label = vapply(age_band, age_band_to_label, character(1))) %>%
  arrange(age_lo_m)

# assegna age_band ai soggetti
dd <- dd %>% mutate(age_band = vapply(age_m, assign_age_band, character(1)))

# check: tutte le age_band dei soggetti devono esistere nella dimensione bande
missing_bands <- setdiff(unique(dd$age_band), age_bands$age_band)
missing_bands <- missing_bands[!is.na(missing_bands)]
if (length(missing_bands) > 0) {
  stop(
    "Alcuni soggetti hanno age_band non presente in age_bands (incoerenza bande).\n",
    paste(missing_bands, collapse = ", ")
  )
}

# ============================================================
# 5) Funzioni: percentile mid-P + PP preliminari
# ============================================================
score_to_pp_prelim <- function(fit_obj, age_y, score_raw) {
  bd <- fit_obj$bd
  minScore <- fit_obj$minScore
  score_shift <- score_raw - minScore
  
  pA <- predictAll(fit_obj$fit, newdata = data.frame(age_y = age_y))
  
  # mid-P per discreto bounded
  p_le <- pBB(q = score_shift,     mu = pA$mu, sigma = pA$sigma, bd = bd)
  p_lt <- pBB(q = score_shift - 1, mu = pA$mu, sigma = pA$sigma, bd = bd)
  p_eq <- pmax(0, p_le - p_lt)
  prob <- p_lt + 0.5 * p_eq
  
  # cap a ±3 SD
  prob[prob > pnorm( 3)] <- pnorm( 3)
  prob[prob < pnorm(-3)] <- pnorm(-3)
  
  percentile <- round(prob * 100, 1)
  PP <- round(qnorm(prob) * 3 + 10)
  PP[PP < 1] <- 1
  PP[PP > 19] <- 19
  
  list(percentile = percentile, PP = PP)
}

make_task_table_prelim <- function(task, fit_obj, minScore, maxScore, age_bands_df) {
  grezzi <- seq(minScore, maxScore, by = 1)
  
  grid <- tidyr::expand_grid(
    task = task,
    age_band = age_bands_df$age_band,
    age_ref_y = age_bands_df$age_ref_y,
    grezzo = grezzi
  )
  
  sc <- score_to_pp_prelim(fit_obj, grid$age_ref_y, grid$grezzo)
  
  grid %>%
    mutate(percentile = sc$percentile, PP_prelim = sc$PP) %>%
    arrange(task, age_band, grezzo)
}

# ============================================================
# 6) 2a PRELIM: tabelle grezzo -> PP_prelim per banda
# ============================================================
tasks_tables <- list()
for (i in seq_len(nrow(tasks_spec))) {
  tk <- tasks_spec$task[i]
  cat("Tabella PRELIM:", tk, "\n")
  tasks_tables[[tk]] <- make_task_table_prelim(
    task = tk,
    fit_obj = fits[[tk]],
    minScore = tasks_spec$minScore[i],
    maxScore = tasks_spec$maxScore[i],
    age_bands_df = age_bands
  )
}

tab_prelim <- bind_rows(tasks_tables)

# Collassa eventuali duplicati (robusto) su chiave
dup_keys <- tab_prelim %>% count(task, age_band, grezzo) %>% filter(n > 1)
if (nrow(dup_keys) > 0) {
  warning(
    "Trovati duplicati in tab_prelim su (task, age_band, grezzo). Li sto collassando (mean + round).\n",
    paste(capture.output(print(head(dup_keys, 20))), collapse = "\n")
  )
  tab_prelim <- tab_prelim %>%
    group_by(task, age_band, grezzo) %>%
    summarise(
      age_ref_y  = mean(age_ref_y),
      percentile = mean(percentile),
      PP_prelim  = round(mean(PP_prelim)),
      .groups = "drop"
    )
}

# Monotonicità grezzo->PP prelim
if (ENFORCE_MONOTONE) {
  tab_prelim <- tab_prelim %>%
    group_by(task, age_band) %>%
    arrange(grezzo, .by_group = TRUE) %>%
    mutate(PP_prelim = cummax(PP_prelim)) %>%
    ungroup()
}

# Aggiungi label + chiavi sorting e ordina bene
tab_prelim <- tab_prelim %>%
  left_join(
    age_bands %>% select(age_band, age_band_label, age_lo_m, age_hi_m, age_ref_m),
    by = "age_band"
  ) %>%
  arrange(task, age_lo_m, grezzo)

write_csv(
  tab_prelim %>%
    select(task, age_band, age_band_label,
           age_lo_m, age_hi_m, age_ref_m, age_ref_y,
           grezzo, percentile, PP_prelim),
  file.path(OUT_DIR, "tasks_conversion_tables_grezzo_to_PP_by_ageband_PRELIM.csv")
)

# ============================================================
# 7) 2b PRELIM: scoring campione con lookup tab_prelim
# ============================================================
dd_long <- dd %>%
  mutate(.row_id = row_number()) %>%
  select(.row_id, age_band, all_of(tasks_spec$raw_col)) %>%
  pivot_longer(
    cols = all_of(tasks_spec$raw_col),
    names_to = "raw_col", values_to = "grezzo"
  ) %>%
  mutate(task = str_replace(raw_col, "_grezzo$", "")) %>%
  select(.row_id, task, age_band, grezzo)

dup_long <- dd_long %>% count(.row_id, task) %>% filter(n > 1)
if (nrow(dup_long) > 0) stop("Duplicati inattesi in dd_long per (.row_id, task).")

dd_long_prelim <- dd_long %>%
  left_join(
    tab_prelim %>% select(task, age_band, grezzo, PP_prelim),
    by = c("task","age_band","grezzo"),
    relationship = "many-to-one"
  )

na_n <- sum(is.na(dd_long_prelim$PP_prelim))
if (na_n > 0) {
  bad <- dd_long_prelim %>%
    filter(is.na(PP_prelim)) %>%
    count(task, age_band, grezzo, sort = TRUE) %>%
    head(20)
  warning(
    "Trovati ", na_n, " NA in PP_prelim dopo lookup.\n",
    paste(capture.output(print(bad)), collapse = "\n")
  )
}

dd_pp_prelim_wide <- dd_long_prelim %>%
  mutate(pp_col = paste0(task, "_PP_prelim")) %>%
  select(.row_id, pp_col, PP_prelim) %>%
  pivot_wider(id_cols = .row_id, names_from = pp_col, values_from = PP_prelim)

dd_out_prelim <- dd %>%
  mutate(.row_id = row_number()) %>%
  left_join(dd_pp_prelim_wide, by = ".row_id") %>%
  select(-.row_id)

write_csv(dd_out_prelim, file.path(OUT_DIR, "standardization_sample_scored_PP_PRELIM.csv"))

# ============================================================
# 8) 2c OFFICIAL: forced centering Wechsler-style per task x age_band
# ============================================================
pp_prelim_cols <- grep("_PP_prelim$", names(dd_out_prelim), value = TRUE)

band_stats <- dd_out_prelim %>%
  select(age_band, all_of(pp_prelim_cols)) %>%
  pivot_longer(cols = all_of(pp_prelim_cols), names_to = "pp_col", values_to = "PP_prelim") %>%
  mutate(task = str_replace(pp_col, "_PP_prelim$", "")) %>%
  group_by(task, age_band) %>%
  summarise(
    m = mean(PP_prelim, na.rm = TRUE),
    s = sd(PP_prelim, na.rm = TRUE),
    n = sum(!is.na(PP_prelim)),
    .groups = "drop"
  )

recalibrate_pp <- function(PP_prelim, m, s,
                           target_mean = 10, target_sd = 3, force_sd = FALSE) {
  if (is.na(PP_prelim) || is.na(m)) return(NA_real_)
  
  if (!force_sd) {
    PP_adj <- PP_prelim + (target_mean - m)
  } else {
    if (is.na(s) || s == 0) return(NA_real_)
    PP_adj <- target_mean + target_sd * (PP_prelim - m) / s
  }
  
  PP_off <- round(PP_adj)
  PP_off[PP_off < 1]  <- 1
  PP_off[PP_off > 19] <- 19
  PP_off
}

tab_official <- tab_prelim %>%
  # tab_prelim ha già label + chiavi; qui aggiungiamo stats e PP_official
  left_join(band_stats, by = c("task","age_band")) %>%
  mutate(
    PP_official = mapply(
      FUN = recalibrate_pp,
      PP_prelim = PP_prelim, m = m, s = s,
      MoreArgs = list(target_mean = TARGET_MEAN_PP, target_sd = TARGET_SD_PP, force_sd = FORCE_SD)
    )
  )

if (ENFORCE_MONOTONE) {
  tab_official <- tab_official %>%
    group_by(task, age_band) %>%
    arrange(grezzo, .by_group = TRUE) %>%
    mutate(PP_official = cummax(PP_official)) %>%
    ungroup()
}

# riordina bene e salva
tab_official <- tab_official %>%
  arrange(task, age_lo_m, grezzo)

write_csv(
  tab_official %>%
    select(task, age_band, age_band_label,
           age_lo_m, age_hi_m, age_ref_m, age_ref_y,
           grezzo, percentile, PP_prelim, PP_official),
  file.path(OUT_DIR, "tasks_conversion_tables_grezzo_to_PP_by_ageband_OFFICIAL.csv")
)

# ============================================================
# 9) 2d OFFICIAL: scoring campione con lookup tab_official
# ============================================================
dd_long_off <- dd_long %>%
  left_join(
    tab_official %>% select(task, age_band, grezzo, PP_official),
    by = c("task","age_band","grezzo"),
    relationship = "many-to-one"
  )

na_n2 <- sum(is.na(dd_long_off$PP_official))
if (na_n2 > 0) {
  bad2 <- dd_long_off %>%
    filter(is.na(PP_official)) %>%
    count(task, age_band, grezzo, sort = TRUE) %>%
    head(20)
  warning(
    "Trovati ", na_n2, " NA in PP_official dopo lookup.\n",
    paste(capture.output(print(bad2)), collapse = "\n")
  )
}

dd_pp_off_wide <- dd_long_off %>%
  mutate(pp_col = paste0(task, "_PP")) %>%
  select(.row_id, pp_col, PP_official) %>%
  pivot_wider(id_cols = .row_id, names_from = pp_col, values_from = PP_official)

dd_out_official <- dd %>%
  mutate(.row_id = row_number()) %>%
  left_join(dd_pp_off_wide, by = ".row_id") %>%
  select(-.row_id)

write_csv(dd_out_official, file.path(OUT_DIR, "standardization_sample_scored_PP_OFFICIAL.csv"))

# ============================================================
# 10) SANITY CHECKS (OFFICIAL)
# ============================================================
pp_cols <- grep("_PP$", names(dd_out_official), value = TRUE)

cat("\nSANITY CHECK A (OFFICIAL): mean(PP) per age_band (ordinato)\n")
means_by_band <- dd_out_official %>%
  left_join(age_bands %>% select(age_band, age_lo_m, age_band_label), by = "age_band") %>%
  select(age_band, age_band_label, age_lo_m, all_of(pp_cols)) %>%
  group_by(age_band, age_band_label, age_lo_m) %>%
  summarise(across(all_of(pp_cols), ~mean(.x, na.rm = TRUE)), .groups = "drop") %>%
  arrange(age_lo_m) %>%
  select(-age_lo_m)
print(means_by_band, n = nrow(means_by_band))

cat("\nSANITY CHECK B (OFFICIAL): correlazione entro-banda (eta centrata nella banda)\n")
dd_tmp <- dd_out_official %>%
  group_by(age_band) %>%
  mutate(age_y_centered = age_y - mean(age_y, na.rm = TRUE)) %>%
  ungroup()

pp_within_band_cor <- sapply(pp_cols, function(cc) cor(dd_tmp$age_y_centered, dd_tmp[[cc]], use = "pairwise.complete.obs"))
print(round(pp_within_band_cor, 3))

cat("\nSANITY CHECK C (OFFICIAL): correlazione globale PP ~ eta (age_y)\n")
pp_age_cor <- sapply(pp_cols, function(cc) cor(dd_out_official$age_y, dd_out_official[[cc]], use = "pairwise.complete.obs"))
print(round(pp_age_cor, 3))

cat("\nOK: generate tabelle PRELIM e OFFICIAL e scoring corrispondenti.\n")
cat("FORCE_SD = ", FORCE_SD, " (", ifelse(FORCE_SD, "mean+SD", "mean-only"), ")\n", sep = "")
