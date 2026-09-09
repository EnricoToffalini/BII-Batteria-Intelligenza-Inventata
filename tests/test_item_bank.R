source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)
spec <- read_bii_spec(root)

required_columns <- c(
  "item_id", "subtest", "item_type", "order", "family", "difficulty_rank",
  "prompt", "scoring_key", "scoring_rubric", "review_status"
)
item_files <- list.files(file.path(root, "items", "source"), pattern = "\\.csv$", full.names = TRUE)
if (length(item_files) == 0L) stop("Nessun item bank CSV trovato.")

all_ids <- character()
for (item_file in item_files) {
  items <- utils::read.csv(item_file, stringsAsFactors = FALSE, check.names = FALSE)
  missing_columns <- setdiff(required_columns, names(items))
  if (length(missing_columns)) stop(basename(item_file), ": colonne mancanti: ", paste(missing_columns, collapse = ", "))
  if (any(!items$subtest %in% names(spec$subtests))) stop(basename(item_file), ": subtest sconosciuto.")
  if (any(!grepl("^[A-Z]{2}-(PR|SC)-[0-9]{2}$", items$item_id))) stop(basename(item_file), ": formato item_id non valido.")
  if (anyDuplicated(items$item_id)) stop(basename(item_file), ": item_id duplicati.")
  if (any(!items$item_type %in% c("practice", "scored"))) stop(basename(item_file), ": item_type non valido.")
  scored <- items[items$item_type == "scored", , drop = FALSE]
  if (any(scored$prompt == "" | scored$scoring_key == "" | scored$scoring_rubric == "")) stop(basename(item_file), ": item scored incompleto.")
  all_ids <- c(all_ids, items$item_id)
}
if (anyDuplicated(all_ids)) stop("item_id duplicato fra file diversi.")

sp <- utils::read.csv(file.path(root, spec$subtests$SP$item_bank$path), stringsAsFactors = FALSE, check.names = FALSE)
if (sum(sp$item_type == "practice") != spec$subtests$SP$n_practice_items ||
    sum(sp$item_type == "scored") != spec$subtests$SP$item_bank$n_scored_items_current ||
    sum(sp$item_type == "scored") > spec$subtests$SP$n_scored_items) {
  stop("SP.csv: conteggi incoerenti con la spec.")
}
