#!/usr/bin/env Rscript

# Punteggi grezzi dai dati raccolti: una riga per persona e subtest.
#
# Prima controlla i file con gli stessi checker di R/data/ e si ferma se non
# sono validi; poi corregge ogni protocollo con lo scorer della batteria
# (score_subtest_record() o score_fixed_time_record()). Non calcola punteggi
# ponderati, indici o QI: le norme della BII sono simulate e non vanno
# applicate a dati raccolti come se fossero empiriche.
#
#   Rscript R/data/score_collected.R data/collected/responses.csv \
#     --timed=data/collected/timed_records.csv --out=data/collected/raw_scores.csv
#
# Senza --out il risultato viene solo stampato.

raw_score_columns <- c("subject_id", "age_months", "subtest", "raw_score", "raw_max", "status", "notes")

score_collected <- function(responses_path = NULL, timed_path = NULL, root = NULL) {
  if (is.null(root)) root <- normalizePath(".", winslash = "/", mustWork = TRUE)
  if (is.null(responses_path) && is.null(timed_path)) stop("Indicare almeno un file di dati raccolti.", call. = FALSE)

  # Ambienti separati: i checker e il motore definiscono funzioni omonime.
  engine <- new.env(parent = globalenv())
  sys.source(file.path(root, "R", "items", "load_items.R"), envir = engine)
  sys.source(file.path(root, "R", "scoring", "administer.R"), envir = engine)
  spec <- engine$bii_spec(root)
  out <- list()

  if (!is.null(responses_path)) {
    checker <- new.env(parent = globalenv())
    sys.source(file.path(root, "R", "data", "check_responses.R"), envir = checker)
    responses <- checker$check_response_file(responses_path, root = root)
    contexts <- list()
    groups <- split(seq_len(nrow(responses)), paste(responses$subject_id, responses$subtest, sep = "::"), drop = TRUE)
    for (rows in groups) {
      record <- responses[rows, , drop = FALSE]
      id <- record$subtest[1]
      if (is.null(contexts[[id]])) contexts[[id]] <- engine$load_item_bank(id, root, spec)
      context <- contexts[[id]]
      raw_max <- as.numeric(context$spec$scoring$raw_max)
      scored <- tryCatch(engine$score_subtest_record(id, record, context = context), error = function(e) e)
      out[[length(out) + 1L]] <- if (inherits(scored, "error")) {
        # Protocollo che lo scorer non puo correggere (per esempio item
        # mancanti): si segnala, non si inventa un punteggio.
        data.frame(subject_id = record$subject_id[1], age_months = as.integer(record$age_months[1]), subtest = id,
                   raw_score = NA_real_, raw_max = raw_max, status = "incomplete_record",
                   notes = conditionMessage(scored))
      } else {
        data.frame(subject_id = record$subject_id[1], age_months = as.integer(record$age_months[1]), subtest = id,
                   raw_score = scored$raw_score, raw_max = raw_max, status = scored$reason,
                   notes = paste(scored$warnings, collapse = " "))
      }
    }
  }

  if (!is.null(timed_path)) {
    timed <- new.env(parent = globalenv())
    sys.source(file.path(root, "R", "data", "check_timed_records.R"), envir = timed)
    checked <- timed$check_timed_record_file(timed_path, root = root)
    if (nrow(checked)) {
      out[[length(out) + 1L]] <- data.frame(
        subject_id = checked$subject_id, age_months = as.integer(checked$age_months), subtest = checked$subtest,
        raw_score = checked$raw_score,
        raw_max = vapply(checked$subtest, function(id) as.numeric(spec$subtests[[id]]$scoring$raw_max), numeric(1)),
        status = "complete", notes = checked$warnings
      )
    }
  }

  if (!length(out)) {
    return(as.data.frame(stats::setNames(replicate(length(raw_score_columns), character(0), simplify = FALSE), raw_score_columns)))
  }
  result <- do.call(rbind, out)
  # Ordine leggibile: persona, poi subtest nell'ordine della batteria.
  order_ids <- unlist(spec$battery$subtest_order, use.names = FALSE)
  result <- result[order(result$subject_id, match(result$subtest, order_ids)), raw_score_columns]
  rownames(result) <- NULL
  result
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  flag <- function(name) {
    hit <- grep(paste0("^--", name, "="), args, value = TRUE)
    if (length(hit)) sub(paste0("^--", name, "="), "", hit[1]) else NULL
  }
  positional <- args[!grepl("^--", args)]
  if (length(positional) > 1L || (!length(positional) && is.null(flag("timed")))) {
    stop("Uso: Rscript R/data/score_collected.R responses.csv [--timed=timed_records.csv] [--out=raw_scores.csv]")
  }
  result <- score_collected(
    responses_path = if (length(positional)) positional[1] else NULL,
    timed_path = flag("timed"),
    root = normalizePath(".", winslash = "/", mustWork = TRUE)
  )
  print(result, row.names = FALSE)
  out_path <- flag("out")
  if (!is.null(out_path)) {
    utils::write.csv(result, out_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
    cat("Scritto ", out_path, ".\n", sep = "")
  }
  not_complete <- sum(result$status != "complete")
  if (not_complete) cat(not_complete, " protocolli senza punteggio grezzo: vedere status e notes.\n", sep = "")
  cat("Solo punteggi grezzi: nessun punteggio ponderato, indice o QI. Le norme BII sono simulate.\n")
}
