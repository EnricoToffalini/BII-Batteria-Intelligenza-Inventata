#!/usr/bin/env Rscript

# Rigenera i moduli di registrazione a partire dalla spec e, per i subtest
# item-level, dall'item bank.
#
# I moduli sono artefatti derivati. Quelli item-level devono coincidere con
# items/source/<ID>.csv; quelli fixed_time contengono una sola osservazione con
# le componenti aggregate dichiarate nella spec.
#
#   Rscript R/build/build_record_forms.R

bii_build_root <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) == 1L) {
    script <- normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE))
  }
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

# Colonne aggiuntive richieste da singoli subtest, dichiarate qui e non
# nascoste dentro il generatore.
BII_RECORD_FORM_EXTRA <- list(
  SP = "query_used"
)

# Contenuto del modulo, senza scrivere nulla: cosi i test possono confrontare
# il file versionato con quello atteso senza modificare artefatti.
record_form_table <- function(subtest_id, root) {
  spec <- bii_spec(root)
  st <- spec$subtests[[subtest_id]]
  if (is.null(st)) stop("Subtest sconosciuto nella spec: ", subtest_id, ".", call. = FALSE)

  if (identical(st$administration$route_type, "fixed_time")) {
    form <- data.frame(
      subject_id = "",
      age_months = "",
      subtest = subtest_id,
      stringsAsFactors = FALSE
    )
    for (component in names(st$scoring$components)) form[[component]] <- ""
    form$actual_time_minutes <- ""
    form$procedure_notes <- ""
    return(form)
  }

  context <- load_item_bank(subtest_id, root, spec)
  items <- rbind(context$practice, context$items)
  items <- items[order(items$item_type != "practice", items$order), , drop = FALSE]

  form <- data.frame(
    subject_id = "",
    age_months = "",
    subtest = subtest_id,
    item_id = items$item_id,
    item_type = items$item_type,
    order = items$order,
    administration_status = "",
    response = "",
    stringsAsFactors = FALSE
  )

  # Se la spec dichiara un punteggio derivato da componenti, il modulo raccoglie
  # le componenti e NON una colonna item_score: un punteggio scritto a mano
  # verrebbe ignorato dallo scorer, quindi non va nemmeno chiesto.
  derived_from <- unlist(context$spec$scoring$derived_from, use.names = FALSE)
  if (is.null(derived_from)) {
    form$item_score <- ""
  } else {
    for (component in derived_from) form[[component]] <- ""
  }

  for (extra in BII_RECORD_FORM_EXTRA[[subtest_id]]) form[[extra]] <- ""

  # Il ritardo effettivo si registra solo dove la spec prevede una finestra.
  if (!is.null(context$spec$administration$retrieval_window_minutes)) {
    form$delay_minutes <- ""
  }

  form$response_time_seconds <- ""
  form$notes <- ""
  form
}

# Hanno un modulo i subtest con item bank e le prove fixed_time, il cui record
# e aggregato e quindi non dipende dall'esistenza degli stimoli definitivi.
record_form_subtests <- function(root) {
  spec <- bii_spec(root)
  ids <- spec$battery$subtest_order
  ids[vapply(spec$subtests[ids], function(st) {
    !is.null(st$item_bank) || identical(st$administration$route_type, "fixed_time")
  }, logical(1))]
}

record_form_path <- function(subtest_id, root) {
  file.path(root, "materials", "record_forms", paste0(subtest_id, "_record_form.csv"))
}

record_form_lines <- function(subtest_id, root) {
  target <- tempfile(fileext = ".csv")
  on.exit(unlink(target), add = TRUE)
  utils::write.csv(record_form_table(subtest_id, root), target, row.names = FALSE, quote = FALSE, na = "")
  readLines(target, warn = FALSE)
}

build_record_form <- function(subtest_id, root) {
  path <- record_form_path(subtest_id, root)
  writeLines(record_form_lines(subtest_id, root), path)
  path
}

if (sys.nframe() == 0L) {
  root <- bii_build_root()
  source(file.path(root, "R", "items", "load_items.R"))
  for (id in record_form_subtests(root)) {
    message("[FORM] ", basename(build_record_form(id, root)))
  }
  message("[OK] Moduli di registrazione rigenerati dalla spec e dagli item bank.")
}
