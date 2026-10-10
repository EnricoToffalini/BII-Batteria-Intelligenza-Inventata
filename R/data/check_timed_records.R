#!/usr/bin/env Rscript

# Controllo dei record aggregati delle prove a tempo (route_type fixed_time,
# oggi CL e SS). E separato da check_responses.R, che controlla righe
# item-level: qui ogni riga e un intero foglio somministrato a una persona.
#
# Componenti, range e vincoli fra componenti vengono dalla spec; il punteggio
# grezzo e calcolato da score_fixed_time_record(), lo stesso usato per un
# singolo modulo. Il comando non modifica file e non produce punteggi normativi.
#
#   Rscript R/data/check_timed_records.R data/collected/timed_records.csv

timed_id_columns <- c("subject_id", "age_months", "subtest")
timed_procedure_columns <- c("actual_time_minutes", "procedure_notes")

# Ambiente separato per il motore: evita che il load_item_bank() di
# check_responses.R, se caricato nella stessa sessione, venga usato al suo posto.
bii_timed_engine <- function(root) {
  engine <- new.env(parent = globalenv())
  sys.source(file.path(root, "R", "items", "load_items.R"), envir = engine)
  sys.source(file.path(root, "R", "scoring", "administer.R"), envir = engine)
  engine
}

timed_subtest_ids <- function(spec) {
  ids <- unlist(spec$battery$subtest_order, use.names = FALSE)
  is_timed <- vapply(
    ids, function(id) identical(spec$subtests[[id]]$administration$route_type, "fixed_time"),
    logical(1)
  )
  ids[is_timed]
}

# Colonne del modello data/templates/timed_records.csv: identificativi,
# unione delle componenti delle prove fixed_time nell'ordine della batteria,
# dati procedurali. Una componente condivisa (omissions) compare una volta.
timed_record_columns <- function(spec) {
  components <- lapply(timed_subtest_ids(spec), function(id) names(spec$subtests[[id]]$scoring$components))
  c(timed_id_columns, unique(unlist(components, use.names = FALSE)), timed_procedure_columns)
}

check_timed_record_file <- function(path, root = NULL) {
  if (is.null(root)) root <- normalizePath(".", winslash = "/", mustWork = TRUE)
  engine <- bii_timed_engine(root)
  spec <- engine$bii_spec(root)
  if (!file.exists(path)) stop("File dei record timed non trovato: ", path, call. = FALSE)

  # Tutto come testo: un valore come "abc" o "2,5" deve diventare un errore
  # leggibile, non un NA silenzioso o una colonna reinterpretata.
  records <- utils::read.csv(
    path, stringsAsFactors = FALSE, check.names = FALSE, colClasses = "character",
    na.strings = c("", "NA"), strip.white = TRUE, encoding = "UTF-8"
  )
  required <- c(timed_id_columns, timed_procedure_columns)
  missing <- setdiff(required, names(records))
  if (length(missing)) stop("Colonne mancanti: ", paste(missing, collapse = ", "), call. = FALSE)

  timed_ids <- timed_subtest_ids(spec)
  components_of <- lapply(stats::setNames(timed_ids, timed_ids), function(id) names(spec$subtests[[id]]$scoring$components))
  present <- intersect(timed_ids, unique(records$subtest))
  missing_components <- setdiff(unlist(components_of[present], use.names = FALSE), names(records))
  if (length(missing_components)) {
    stop("Colonne mancanti: ", paste(missing_components, collapse = ", "), call. = FALSE)
  }

  result <- data.frame(
    subject_id = records$subject_id, age_months = records$age_months, subtest = records$subtest,
    raw_score = rep(NA_real_, nrow(records)), warnings = rep("", nrow(records)),
    stringsAsFactors = FALSE
  )
  if (!nrow(records)) return(invisible(result))

  problems <- character()
  # La riga 1 del file e l'intestazione: il primo record e la riga 2.
  add_problem <- function(i, message) problems <<- c(problems, sprintf("riga %d: %s", i + 1L, message))
  blank <- function(x) is.na(x) | !nzchar(x)

  for (i in seq_len(nrow(records))) {
    row <- records[i, , drop = FALSE]
    id <- row$subtest
    if (blank(row$subject_id)) add_problem(i, "subject_id mancante.")
    if (blank(id) || !id %in% names(spec$subtests)) {
      add_problem(i, paste0("subtest sconosciuto: ", if (blank(id)) "(vuoto)" else id, "."))
      next
    }
    if (!id %in% timed_ids) {
      add_problem(i, paste0(id, " non e una prova a tempo; usare R/data/check_responses.R."))
      next
    }
    st <- spec$subtests[[id]]

    if (blank(row$age_months) || !grepl("^[0-9]+$", row$age_months)) {
      add_problem(i, "age_months deve essere un numero intero di mesi.")
    } else {
      age_error <- tryCatch(
        {
          engine$subtest_age_is_eligible(row$age_months, st, spec$battery)
          NULL
        },
        error = conditionMessage
      )
      if (!is.null(age_error)) add_problem(i, age_error)
    }

    # Una componente di un'altra prova compilata indica quasi sempre un codice
    # subtest sbagliato: non la si ignora.
    foreign <- setdiff(unlist(components_of, use.names = FALSE), components_of[[id]])
    foreign <- intersect(foreign, names(records))
    filled_foreign <- foreign[!vapply(foreign, function(col) blank(row[[col]]), logical(1))]
    if (length(filled_foreign)) {
      add_problem(i, paste0(
        "colonne non previste per ", id, " compilate: ",
        paste(filled_foreign, collapse = ", "), "."
      ))
    }

    # Tempo vuoto: dato mancante, segnalato come warning dallo scorer.
    # Tempo presente ma non interpretabile o non positivo: errore di trascrizione.
    record <- data.frame(subtest = id, stringsAsFactors = FALSE)
    for (component in components_of[[id]]) record[[component]] <- row[[component]]
    if (!blank(row$actual_time_minutes)) {
      actual <- suppressWarnings(as.numeric(row$actual_time_minutes))
      if (is.na(actual) || !is.finite(actual) || actual <= 0) {
        add_problem(i, "actual_time_minutes deve essere un numero positivo di minuti (decimali con il punto).")
      } else {
        record$actual_time_minutes <- actual
      }
    }

    scored <- tryCatch(
      engine$score_fixed_time_record(id, record, context = list(subtest = id, spec = st, battery = spec$battery, root = spec$root)),
      error = function(e) {
        add_problem(i, conditionMessage(e))
        NULL
      }
    )
    if (!is.null(scored)) {
      result$raw_score[i] <- scored$raw_score
      result$warnings[i] <- paste(scored$warnings, collapse = " ")
    }
  }

  key <- paste(records$subject_id, records$subtest, sep = "::")
  for (i in which(duplicated(key) & !blank(records$subject_id))) {
    first <- match(key[i], key)
    add_problem(i, sprintf("stesso subject_id e subtest della riga %d.", first + 1L))
  }

  if (length(problems)) {
    # Ordine del file, non ordine di scoperta.
    line_numbers <- as.integer(sub("^riga ([0-9]+):.*$", "\\1", problems))
    problems <- problems[order(line_numbers)]
    stop(
      "Record timed non validi (", length(problems), " problemi):\n  ",
      paste(problems, collapse = "\n  "), call. = FALSE
    )
  }
  invisible(result)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 1L) stop("Uso: Rscript R/data/check_timed_records.R percorso/al/file.csv")
  checked <- check_timed_record_file(args[[1]], root = normalizePath(".", winslash = "/", mustWork = TRUE))
  cat("OK: ", nrow(checked), " record timed validi.\n", sep = "")
  flagged <- which(nzchar(checked$warnings))
  for (i in flagged) {
    cat("  avviso riga ", i + 1L, " (", checked$subject_id[i], ", ", checked$subtest[i], "): ",
        checked$warnings[i], "\n", sep = "")
  }
  cat("Gli avvisi sul tempo non cambiano il punteggio grezzo. Nessun punteggio normativo e stato calcolato.\n")
}
