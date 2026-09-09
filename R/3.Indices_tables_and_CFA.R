############################################################
# 03_Indices_tables_and_CFA.R  (INDICI + TABELLE + CFA)
#
# BII (batteria fittizia a scopo didattico)
#
# Pipeline:
# - File 1: fit continuous norming (GAMLSS) sui grezzi
# - File 2: tabelle grezzo -> PP per age_band + scoring PP nello standardization sample
# - File 3 (QUESTO):
#     1) calcolo indici come somme di PP (mai un solo subtest)
#     2) tabelle sommaPP -> SS (M=100, SD=15)
#        NON per ogni age_band (troppo oneroso), ma per 3 macro-gruppi:
#          * 6-10 anni
#          * 10-16 anni
#          * 16-22 anni
#     3) CFA CORE12 (12 indicatori, 6 fattori correlati vs 1 fattore)
#
# Nota psicometrica:
# - I PP nel file 2 sono centrati a M=10 per age_band; la SD non e' forzata a 3 (default).
# - Quindi la SD della sommaPP NON va ricavata assumendo SD=3 e usando solo la correlazione.
# - Qui stimiamo empiricamente mu e sd della sommaPP per ciascun macro-gruppo d'eta',
#   e costruiamo le tabelle da quella distribuzione (coerente con la pipeline).
#
# OUTPUT (in OUT_DIR):
# - indices_conversion_tables_sommaPP_to_SS_by_agegroup.csv
# - standardization_sample_scored_PP_and_indices.csv
# - CFA_fit_summary.txt
############################################################

rm(list = ls())

# ============================================================
# 0) Pacchetti
# ============================================================
pkgs <- c("dplyr","tidyr","readr","stringr","tibble","lavaan","semTools")
stopifnot(all(sapply(pkgs, requireNamespace, quietly = TRUE)))

library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(tibble)
library(lavaan)
library(semTools)

# ============================================================
# 1) Impostazioni
# ============================================================
OUT_DIR <- "norms_BII"

# Quale file PP usare:
# - OFFICIAL = output principale del file 2
# - PRELIM   = output preliminare del file 2 (colonne *_PP_prelim)
# - AUTO     = prova OFFICIAL, poi PP, poi PRELIM
VERSION <- "OFFICIAL"  # OFFICIAL | PRELIM | AUTO

TARGET_MEAN_SS <- 100
TARGET_SD_SS   <- 15

# Opzioni di robustezza
CAP_SS <- c(40, 160)          # c(min, max) oppure NULL
ENFORCE_MONOTONE <- TRUE      # impone monotonicita' sulle tabelle
MIN_N_PER_GROUP <- 30         # warning se macro-gruppi piccoli

# ============================================================
# 2) Caricamento dati PP
# ============================================================
if (!dir.exists(OUT_DIR)) stop("Cartella OUT_DIR non trovata: ", OUT_DIR)

pick_input_file <- function(out_dir, version) {
  if (version == "OFFICIAL") return(file.path(out_dir, "standardization_sample_scored_PP_OFFICIAL.csv"))
  if (version == "PRELIM")   return(file.path(out_dir, "standardization_sample_scored_PP_PRELIM.csv"))
  
  cand <- c(
    file.path(out_dir, "standardization_sample_scored_PP_OFFICIAL.csv"),
    file.path(out_dir, "standardization_sample_scored_PP.csv"),
    file.path(out_dir, "standardization_sample_scored_PP_PRELIM.csv")
  )
  cand <- cand[file.exists(cand)]
  if (length(cand) == 0) stop("Nessun file PP trovato in ", out_dir)
  cand[1]
}

IN_FILE <- pick_input_file(OUT_DIR, VERSION)
dd <- readr::read_csv(IN_FILE, show_col_types = FALSE)

# Se PRELIM, rinomina *_PP_prelim -> *_PP
if (any(grepl("_PP_prelim$", names(dd)))) {
  pp_pre <- grep("_PP_prelim$", names(dd), value = TRUE)
  dd <- dd %>% rename_with(~ stringr::str_replace(.x, "_PP_prelim$", "_PP"), all_of(pp_pre))
}

# Check colonne essenziali
pp_core12 <- c(
  "SP_PP","RS_PP","MR_PP","RR_PP","MO_PP","RP_PP",
  "SM_PP","PG_PP","CL_PP","SS_PP","CR_PP","DM_PP"
)
miss_pp <- setdiff(pp_core12, names(dd))
if (length(miss_pp) > 0) {
  stop(
    "Mancano colonne PP necessarie (CORE12) nel file: ", basename(IN_FILE), "\n",
    paste(miss_pp, collapse = ", ")
  )
}

# ============================================================
# 3) Macro-gruppi d'eta' per indici (6-10, 10-16, 16-22)
# ============================================================
# Usiamo age_m se presente; altrimenti lo ricaviamo da age_band.

parse_age_band_months <- function(ab_vec) {
  out <- lapply(ab_vec, function(ab) {
    if (is.na(ab) || !nzchar(ab)) return(c(NA_integer_, NA_integer_))
    parts <- strsplit(ab, "-", fixed = TRUE)[[1]]
    if (length(parts) != 2) return(c(NA_integer_, NA_integer_))
    lo <- strsplit(parts[1], ";", fixed = TRUE)[[1]]
    hi <- strsplit(parts[2], ";", fixed = TRUE)[[1]]
    if (length(lo) != 2 || length(hi) != 2) return(c(NA_integer_, NA_integer_))
    lo_m <- as.integer(lo[1]) * 12 + as.integer(lo[2])
    hi_m <- as.integer(hi[1]) * 12 + as.integer(hi[2])
    c(lo_m, hi_m)
  })
  mat <- do.call(rbind, out)
  tibble(age_lo_m = mat[,1], age_hi_m = mat[,2])
}

if (!("age_m" %in% names(dd))) {
  if (!("age_band" %in% names(dd))) stop("Serve 'age_m' o 'age_band' per definire i gruppi d'eta'.")
  tmp <- parse_age_band_months(dd$age_band)
  dd$age_m <- round((tmp$age_lo_m + tmp$age_hi_m) / 2)
}

assign_age_group <- function(age_m) {
  dplyr::case_when(
    age_m >= 72  & age_m < 120 ~ "6-10 anni",
    age_m >= 120 & age_m < 192 ~ "11-16 anni",
    age_m >= 192 & age_m <= 264 ~ "17-22 anni",
    TRUE ~ NA_character_
  )
}

dd <- dd %>%
  mutate(
    age_group = assign_age_group(age_m),
    age_group = factor(age_group, levels = c("6-10 anni","11-16 anni","17-22 anni"))
  )

if (any(is.na(dd$age_group))) {
  bad <- dd %>% filter(is.na(age_group)) %>% distinct(age_m) %>% arrange(age_m)
  stop(
    "Sono presenti eta' fuori dai range 6-22 anni (in mesi) o non classificabili. age_m problematici: ",
    paste(bad$age_m, collapse = ", ")
  )
}

# ============================================================
# 4) Specifica indici (NO supplementari, MAI un solo subtest)
# ============================================================
indices_spec <- list(
  qIC       = c("SP_PP", "RS_PP"),
  qIF       = c("MR_PP", "RR_PP"),
  qVS       = c("MO_PP", "RP_PP"),
  qML       = c("SM_PP", "PG_PP"),
  qVE       = c("CL_PP", "SS_PP"),
  qAR       = c("CR_PP", "DM_PP"),
  QI_rapido = c("SP_PP","RS_PP","MR_PP","RR_PP"),
  QI_totale = c("SP_PP","RS_PP","MR_PP","RR_PP","MO_PP","RP_PP","SM_PP","CL_PP","CR_PP")
)

# ============================================================
# 5) Utility: tabelle sommaPP -> SS per macro-gruppi d'eta'
# ============================================================
make_sumpp_to_SS_tables_by_agegroup <- function(df, pp_cols, index_name) {
  k <- length(pp_cols)
  if (k < 2) stop("Indice con meno di 2 subtest: ", index_name)
  
  sumpp <- rowSums(df[, pp_cols, drop = FALSE])
  
  tmp <- tibble(age_group = df$age_group, sommaPP = sumpp) %>%
    filter(!is.na(age_group), !is.na(sommaPP))
  
  stats <- tmp %>%
    group_by(age_group) %>%
    summarise(
      n = dplyr::n(),
      mu = mean(sommaPP),
      sd = sd(sommaPP),
      .groups = "drop"
    )
  
  if (any(stats$n < MIN_N_PER_GROUP)) {
    warn_groups <- stats %>% filter(n < MIN_N_PER_GROUP) %>% pull(age_group)
    warning(
      index_name, ": alcuni gruppi d'eta' hanno n < ", MIN_N_PER_GROUP,
      " (stima mu/sd poco stabile). Gruppi: ", paste(warn_groups, collapse = ", ")
    )
  }
  
  # Range teorico della sommaPP (PP 1..19)
  sum_range <- seq(k, 19 * k, by = 1)
  
  tab <- tidyr::expand_grid(
    indice = index_name,
    age_group = stats$age_group,
    sommaPP = sum_range
  ) %>%
    left_join(stats, by = "age_group") %>%
    mutate(
      sd = ifelse(is.na(sd) | sd <= 0, 1, sd),
      SS_100_15 = round(TARGET_MEAN_SS + TARGET_SD_SS * ((sommaPP - mu) / sd))
    )
  
  if (!is.null(CAP_SS)) {
    tab <- tab %>%
      mutate(SS_100_15 = pmin(CAP_SS[2], pmax(CAP_SS[1], SS_100_15)))
  }
  
  if (isTRUE(ENFORCE_MONOTONE)) {
    tab <- tab %>%
      group_by(indice, age_group) %>%
      arrange(sommaPP, .by_group = TRUE) %>%
      mutate(SS_100_15 = cummax(SS_100_15)) %>%
      ungroup()
  }
  
  list(table = tab, stats = stats, sommaPP = sumpp)
}

# ============================================================
# 6) Calcolo indici + tabelle
# ============================================================
tables <- list()

for (nm in names(indices_spec)) {
  cols <- indices_spec[[nm]]
  stopifnot(all(cols %in% names(dd)))
  
  res <- make_sumpp_to_SS_tables_by_agegroup(dd, cols, nm)
  tables[[nm]] <- res$table
  
  # Score individuo: usa mu/sd del suo age_group
  mu_vec <- res$stats$mu[match(dd$age_group, res$stats$age_group)]
  sd_vec <- res$stats$sd[match(dd$age_group, res$stats$age_group)]
  sd_vec[is.na(sd_vec) | sd_vec <= 0] <- 1
  
  dd[[paste0(nm, "_sommaPP")]] <- res$sommaPP
  dd[[paste0(nm, "_SS")]] <- round(TARGET_MEAN_SS + TARGET_SD_SS * ((res$sommaPP - mu_vec) / sd_vec))
  
  if (!is.null(CAP_SS)) {
    dd[[paste0(nm, "_SS")]] <- pmin(CAP_SS[2], pmax(CAP_SS[1], dd[[paste0(nm, "_SS")]]))
  }
}

# Salvataggi
out_tables_path <- file.path(OUT_DIR, "indices_conversion_tables_sommaPP_to_SS_by_agegroup.csv")
out_data_path   <- file.path(OUT_DIR, "standardization_sample_scored_PP_and_indices.csv")

readr::write_csv(bind_rows(tables), out_tables_path)
readr::write_csv(dd, out_data_path)

cat("OK: salvate tabelle indici in ", out_tables_path, "\n", sep = "")
cat("OK: salvato dataset con indici in ", out_data_path, "\n", sep = "")

# ============================================================
# 7) CFA CORE12: 6 fattori correlati vs 1 fattore
# ============================================================
model_core12_correlated <- "
  Gc  =~ SP_PP + RS_PP
  Gf  =~ MR_PP + RR_PP
  Gv  =~ MO_PP + RP_PP
  Gwm =~ SM_PP + PG_PP
  Gs  =~ CL_PP + SS_PP
  Glr =~ CR_PP + DM_PP
"

model_core12_onefactor <- "
  g =~ SP_PP + RS_PP + MR_PP + RR_PP + MO_PP + RP_PP + SM_PP + PG_PP + CL_PP + SS_PP + CR_PP + DM_PP
"

fit_meas <- c("chisq","df","pvalue","rmsea","rmsea.ci.lower","rmsea.ci.upper","srmr","cfi","tli","aic","bic")

# MLR per robustezza (PP discreti); per trattarli come ordinali usare WLSMV + ordered.
fit_cor <- cfa(model_core12_correlated, data = dd, std.lv = TRUE, missing = "fiml", estimator = "MLR")
fit_1f  <- cfa(model_core12_onefactor,  data = dd, std.lv = TRUE, missing = "fiml", estimator = "MLR")

sink(file.path(OUT_DIR, "CFA_fit_summary.txt"))
cat("INPUT FILE:\t", basename(IN_FILE), "\n", sep = "")
cat("\n=== CFA CORE12: 6 fattori correlati (MLR) ===\n")
print(fitMeasures(fit_cor, fit.measures = fit_meas))
cat("\n=== CFA CORE12: 1 fattore (MLR) ===\n")
print(fitMeasures(fit_1f, fit.measures = fit_meas))

cat("\n=== Composite reliability (CORE12 correlato) ===\n")
print(semTools::compRelSEM(fit_cor))

sink()

cat("OK: indici + CFA completati.\n")
