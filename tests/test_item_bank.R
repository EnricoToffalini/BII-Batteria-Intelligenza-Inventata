source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)
spec <- read_bii_spec(root)

required_columns <- c(
  "item_id", "subtest", "item_type", "order", "family", "difficulty_rank",
  "difficulty_target", "prompt", "scoring_key", "max_points", "scoring_rubric", "rubric_ref",
  "source_status", "review_status"
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
  if (any(!items$source_status %in% c("mock", "pilot", "empirical"))) stop(basename(item_file), ": source_status non valido.")
  if (any(!items$review_status %in% c("draft", "reviewed", "retired"))) stop(basename(item_file), ": review_status non valido.")
  scored <- items[items$item_type == "scored", , drop = FALSE]
  if (any(scored$prompt == "" | scored$scoring_key == "" | scored$scoring_rubric == "")) stop(basename(item_file), ": item scored incompleto.")
  if (anyDuplicated(scored$order) || !identical(sort(scored$order), seq_len(nrow(scored)))) stop(basename(item_file), ": ordine degli item scored non continuo o duplicato.")
  # La monotonicità della difficoltà dipende da item_ordering dichiarato nella
  # spec: imporla a tutti sarebbe sbagliato per i subtest a insieme fisso, a
  # foglio o a matrice, dove l'ordine non esprime difficoltà crescente.
  scored <- scored[order(scored$order), , drop = FALSE]
  targets <- suppressWarnings(as.numeric(scored$difficulty_target))
  # difficulty_target serve comunque a tutti: è l'input della simulazione.
  if (anyNA(targets)) stop(basename(item_file), ": difficulty_target mancante.")
  for (id in unique(scored$subtest)) {
    ordering <- spec$subtests[[id]]$item_ordering
    rows <- scored$subtest == id
    if (identical(ordering, "increasing_difficulty")) {
      if (is.unsorted(scored$difficulty_rank[rows])) stop(basename(item_file), ": difficoltà non crescente nell'ordine corrente.")
      if (is.unsorted(targets[rows])) stop(basename(item_file), ": difficulty_target non crescente.")
    } else if (identical(ordering, "increasing_difficulty_within_microblock")) {
      if (!"microblock" %in% names(scored)) {
        stop(basename(item_file), ": item_ordering per microblocco ma colonna microblock assente.")
      }
      declared <- unlist(spec$subtests[[id]]$microblocks, use.names = FALSE)
      if (!all(scored$microblock[rows] %in% declared)) {
        stop(basename(item_file), ": microblocco non dichiarato nella spec.")
      }
      for (block in unique(scored$microblock[rows])) {
        in_block <- rows & scored$microblock == block
        if (is.unsorted(scored$difficulty_rank[in_block]) || is.unsorted(targets[in_block])) {
          stop(basename(item_file), ": difficoltà non crescente nel microblocco ", block, ".")
        }
      }
    } else if (!ordering %in% c("fixed_set", "fixed_sheet", "fixed_matrix")) {
      stop(basename(item_file), ": item_ordering non riconosciuto: ", ordering, ".")
    }
  }
  rubric_paths <- sub("#.*$", "", items$rubric_ref)
  if (any(!file.exists(file.path(root, rubric_paths)))) stop(basename(item_file), ": rubrica dettagliata non trovata.")
  for (id in unique(items$subtest)) {
    expected_max <- max(unlist(spec$subtests[[id]]$scoring$item_scores))
    if (any(items$max_points[items$subtest == id] != expected_max)) stop(basename(item_file), ": max_points incoerente con la spec.")
    if (grepl("multiple_choice", spec$subtests[[id]]$response_format)) {
      mc_columns <- c("option_a", "option_b", "option_c", "option_d", "correct_answer", "distractor_rationale")
      missing_mc <- setdiff(mc_columns, names(items))
      if (length(missing_mc)) stop(basename(item_file), ": colonne scelta multipla mancanti: ", paste(missing_mc, collapse = ", "))
      options <- items[items$subtest == id, c("option_a", "option_b", "option_c", "option_d"), drop = FALSE]
      if (any(options == "") || any(apply(options, 1, anyDuplicated) > 0L)) stop(basename(item_file), ": opzioni vuote o duplicate.")
      if (any(!items$correct_answer[items$subtest == id] %in% LETTERS[1:4])) stop(basename(item_file), ": correct_answer non valida.")
      if (any(items$distractor_rationale[items$subtest == id] == "")) stop(basename(item_file), ": rationale dei distrattori mancante.")
    }
  }
  all_ids <- c(all_ids, items$item_id)
}
if (anyDuplicated(all_ids)) stop("item_id duplicato fra file diversi.")

bank_ids <- names(spec$subtests)[vapply(spec$subtests, function(x) !is.null(x$item_bank), logical(1))]
for (id in bank_ids) {
  bank <- utils::read.csv(file.path(root, spec$subtests[[id]]$item_bank$path), stringsAsFactors = FALSE, check.names = FALSE)
  if (sum(bank$item_type == "practice") != spec$subtests[[id]]$n_practice_items ||
      sum(bank$item_type == "scored") != spec$subtests[[id]]$item_bank$n_scored_items_current ||
      sum(bank$item_type == "scored") > spec$subtests[[id]]$n_scored_items) {
    stop(id, ": conteggi item bank incoerenti con la spec.")
  }
}
