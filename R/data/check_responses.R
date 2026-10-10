#!/usr/bin/env Rscript

# Small, deliberately plain checker for a student-maintained response CSV.
# It validates structure and verifies that complete records with scores derived
# from response components can be scored; it does not save computed scores.

response_columns <- c(
  "subject_id", "age_months", "subtest", "item_id", "administration_status",
  "response", "item_score", "recall", "recognition", "delay_minutes",
  "response_time_seconds", "notes"
)

load_item_index <- function(root) {
  files <- list.files(file.path(root, "items", "source"), pattern = "\\.csv$", full.names = TRUE)
  if (!length(files)) stop("Nessun item bank CSV trovato.")
  do.call(rbind, lapply(files, function(path) {
    items <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
    items[c("item_id", "subtest")]
  }))
}

check_response_file <- function(path, root = NULL) {
  if (is.null(root)) root <- normalizePath(".", winslash = "/", mustWork = TRUE)
  source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)
  spec <- read_bii_spec(root)
  if (!file.exists(path)) stop("File risposte non trovato: ", path)
  responses <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE, na.strings = c("", "NA"))
  missing <- setdiff(response_columns, names(responses))
  if (length(missing)) stop("Colonne mancanti: ", paste(missing, collapse = ", "))
  if (!nrow(responses)) return(invisible(responses))
  if (any(is.na(responses$subject_id) | responses$subject_id == "")) stop("subject_id mancante.")
  if (any(is.na(responses$age_months) | responses$age_months < spec$battery$age_range_months$min | responses$age_months > spec$battery$age_range_months$max)) stop("age_months fuori range BII.")
  if (any(!responses$subtest %in% names(spec$subtests))) stop("subtest sconosciuto.")
  allowed_status <- names(spec$battery$administration$response_statuses)
  if (any(!responses$administration_status %in% allowed_status)) stop("administration_status non valido.")
  items <- load_item_index(root)
  if (any(!responses$item_id %in% items$item_id)) stop("item_id non presente nell'item bank corrente.")
  item_subtest <- items$subtest[match(responses$item_id, items$item_id)]
  if (any(item_subtest != responses$subtest)) stop("item_id e subtest non corrispondono.")
  key <- paste(responses$subject_id, responses$subtest, responses$item_id, sep = "::")
  if (anyDuplicated(key)) stop("Righe duplicate per subject_id, subtest e item_id.")
  max_item_score <- vapply(responses$subtest, function(id) {
    scoring <- spec$subtests[[id]]$scoring
    if (!is.null(scoring$item_scores)) return(max(unlist(scoring$item_scores)))
    Inf
  }, numeric(1))
  if (any(!is.na(responses$item_score) & (responses$item_score < 0 | responses$item_score > max_item_score))) stop("item_score fuori dal range previsto per il subtest.")
  inferred <- responses$administration_status %in% c("below_basal", "above_ceiling", "external_missing", "invalidated")
  if (any(inferred & !is.na(responses$item_score))) stop("Gli stati non somministrati o invalidati non devono ricevere un item_score manuale.")

  derived_ids <- names(spec$subtests)[vapply(spec$subtests, function(st) {
    !is.null(st$scoring$derived_from)
  }, logical(1))]
  component_columns <- unique(unlist(lapply(spec$subtests[derived_ids], function(st) {
    unlist(st$scoring$derived_from, use.names = FALSE)
  }), use.names = FALSE))
  if (any(!component_columns %in% names(responses))) {
    stop("Il template non contiene tutte le componenti dichiarate nella spec.")
  }

  ordinary <- !responses$subtest %in% derived_ids
  for (component in component_columns) {
    if (any(ordinary & !is.na(responses[[component]]))) {
      stop(component, " deve restare vuota per i subtest senza punteggio derivato.")
    }
  }
  no_delay <- vapply(responses$subtest, function(id) {
    is.null(spec$subtests[[id]]$administration$retrieval_window_minutes)
  }, logical(1))
  if (any(no_delay & !is.na(responses$delay_minutes))) {
    stop("delay_minutes deve restare vuoto per i subtest senza recupero differito.")
  }
  delay <- suppressWarnings(as.numeric(responses$delay_minutes))
  if (any(!is.na(responses$delay_minutes) & is.na(delay))) {
    stop("delay_minutes deve essere numerico quando compilato.")
  }

  for (id in intersect(unique(responses$subtest), derived_ids)) {
    rows <- responses$subtest == id
    st <- spec$subtests[[id]]
    administered <- rows & responses$administration_status == "administered"
    not_administered <- rows & responses$administration_status != "administered"
    if (any(rows & !is.na(responses$item_score))) {
      stop(id, ": item_score deve restare vuoto; il punteggio si deriva dalle componenti.")
    }
    for (component in unlist(st$scoring$derived_from, use.names = FALSE)) {
      observed <- trimws(as.character(responses[[component]]))
      allowed <- unlist(st$scoring$components[[component]], use.names = FALSE)
      if (any(administered & (is.na(observed) | !observed %in% allowed))) {
        stop(id, ": componente ", component, " mancante o non ammessa.")
      }
      if (any(not_administered & !is.na(observed))) {
        stop(id, ": componente ", component, " compilata per un item non somministrato.")
      }
    }
  }

  # Per ogni protocollo derivato completo, il motore reale deve riuscire a
  # calcolare il grezzo. Cosi le relazioni fra componenti restano definite in
  # un solo posto (R/scoring/administer.R), non duplicate nel checker.
  if (any(responses$subtest %in% derived_ids)) {
    source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)
    derived <- responses[responses$subtest %in% derived_ids, , drop = FALSE]
    group <- interaction(derived$subject_id, derived$subtest, drop = TRUE)
    for (rows in split(seq_len(nrow(derived)), group)) {
      record <- derived[rows, , drop = FALSE]
      id <- record$subtest[1]
      context <- load_item_bank(id, root)
      if (setequal(record$item_id, context$items$item_id)) {
        score_subtest_record(id, record, context = context)
      }
    }
  }
  invisible(responses)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 1L) stop("Uso: Rscript R/data/check_responses.R percorso/al/file.csv")
  checked <- check_response_file(args[[1]], root = normalizePath(".", winslash = "/", mustWork = TRUE))
  cat("OK: ", nrow(checked), " righe valide. Nessun punteggio è stato salvato.\n", sep = "")
}
