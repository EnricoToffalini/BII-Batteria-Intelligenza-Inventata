source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)
spec <- read_bii_spec(root)
subtests <- spec_subtest_table(spec)

stopifnot(nrow(subtests) == spec$battery$n_subtests)
stopifnot(identical(as.integer(table(subtests$role)[c("completion", "core", "supplementary")]), c(3L, 9L, 3L)))
stopifnot(identical(spec$battery$quotients$QI_rapido$components, c("SP", "RS", "MR", "RR")))
stopifnot(identical(spec$battery$quotients$QI_totale$components, subtests$id[subtests$role == "core"]))

# The legacy conversion table remains derived, but until its item-level rebuild
# it must at least cover the exact IDs and raw-score range declared by spec.
norm_file <- file.path(root, "norms_BII", "tasks_conversion_tables_grezzo_to_PP_by_ageband_OFFICIAL.csv")
norms <- utils::read.csv(norm_file, stringsAsFactors = FALSE, check.names = FALSE)
for (i in seq_len(nrow(subtests))) {
  row <- subtests[i, ]
  observed <- norms$grezzo[norms$task == row$id]
  if (!identical(range(observed), c(row$raw_min, row$raw_max))) {
    stop(row$id, ": range nella tabella legacy incoerente con spec.")
  }
}

index_norm_file <- file.path(root, "norms_BII", "indices_conversion_tables_sommaPP_to_SS_by_agegroup.csv")
index_norms <- utils::read.csv(index_norm_file, stringsAsFactors = FALSE, check.names = FALSE)
norming_scores <- c(spec$battery$indices, spec$battery$quotients)
for (score_id in names(norming_scores)) {
  components <- if (!is.null(norming_scores[[score_id]]$modes)) {
    norming_scores[[score_id]]$modes$complete
  } else {
    norming_scores[[score_id]]$components
  }
  observed <- index_norms$sommaPP[index_norms$indice == score_id]
  expected <- c(length(components), 19L * length(components))
  if (!identical(range(observed), expected)) {
    stop(score_id, ": range sommaPP legacy incoerente con la composizione in spec.")
  }
}

age_bands <- unique(norms[c("age_lo_m", "age_hi_m")])
age_bands <- age_bands[order(age_bands$age_lo_m), , drop = FALSE]
continuous_coverage <- age_bands$age_lo_m[-1L] == age_bands$age_hi_m[-nrow(age_bands)] + 1L
if (min(age_bands$age_lo_m) != spec$battery$age_range_months$min ||
    max(age_bands$age_hi_m) != spec$battery$age_range_months$max ||
    !all(continuous_coverage)) {
  stop("Le fasce di età della tabella legacy non coprono il range dichiarato dalla spec.")
}
