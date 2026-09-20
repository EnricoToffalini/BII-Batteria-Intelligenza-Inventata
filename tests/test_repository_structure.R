required_paths <- c(
  "R/0.Data generation.R",
  "R/1.Fitting.R",
  "R/2.Task_tables_norming.R",
  "R/3.Indices_tables_and_CFA.R",
  "R/spec/load_spec.R",
  "R/build/rebuild_all.R",
  "shiny/shinyBII.R",
  "docs/development/CONVENTIONS.md",
  "docs/development/WORK_PACKETS.md",
  "docs/decisions/0001-source-of-truth-migration.md",
  "docs/decisions/0002-age-range-and-pg-grid.md",
  "spec/battery.yml",
  "spec/schemas/battery.schema.json",
  "spec/schemas/subtest.schema.json"
)

missing_paths <- required_paths[!file.exists(file.path(root, required_paths))]
if (length(missing_paths) > 0L) {
  stop("Percorsi obbligatori mancanti: ", paste(missing_paths, collapse = ", "))
}

legacy_subtest_ids <- c(
  "SP", "RS", "CS", "MR", "RR", "QS", "MO", "RP", "MP", "SM", "PG",
  "CL", "SS", "CR", "DM"
)
if (anyDuplicated(legacy_subtest_ids) || length(legacy_subtest_ids) != 15L) {
  stop("Baseline subtest legacy non valida: servono 15 ID univoci.")
}

# The validator will move to spec/ in phase 1. This protects the documented
# baseline until then without treating the scripts as a source of truth.
norm_file <- file.path(root, "norms_BII", "tasks_conversion_tables_grezzo_to_PP_by_ageband_OFFICIAL.csv")
if (!file.exists(norm_file)) stop("Tabella di conversione legacy mancante: ", norm_file)

norms <- utils::read.csv(norm_file, stringsAsFactors = FALSE, check.names = FALSE)
required_columns <- c("task", "grezzo")
if (!all(required_columns %in% names(norms))) {
  stop("Tabella legacy priva delle colonne richieste: ", paste(required_columns, collapse = ", "))
}

norm_ids <- sort(unique(norms$task))
if (!identical(norm_ids, sort(legacy_subtest_ids))) {
  stop("Gli ID nella tabella legacy non coincidono con la baseline documentata.")
}

if (any(!is.finite(norms$grezzo)) || any(norms$grezzo < 0)) {
  stop("La tabella legacy contiene punteggi grezzi invalidi.")
}
