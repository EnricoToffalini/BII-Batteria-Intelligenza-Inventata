#!/usr/bin/env Rscript

# Accordo fra due correttori sulle rubriche aperte 0/1/2 (oggi SP, CS e QS;
# il criterio è open_response_subtests() in R/items/load_items.R).
# Ogni riga e una risposta trascritta, corretta in modo indipendente da due
# persone: score_a e score_b. Il comando controlla il file e riporta, per
# subtest e per item, accordo esatto, kappa pesato quadratico, differenza media
# fra i due correttori e disaccordi di due livelli. Non applica soglie e non
# modifica file: i numeri servono a rivedere rubriche e formazione.
#
#   Rscript R/data/check_scorer_agreement.R data/collected/scorer_agreement.csv

agreement_columns <- c("subject_id", "subtest", "item_id", "response", "score_a", "score_b")

# Kappa pesato quadratico per due vettori di punteggi su categorie ordinate.
# NA se l'accordo atteso per caso e gia perfetto (per esempio un solo valore
# usato da entrambi): il coefficiente non e definito, non vale 1.
weighted_kappa <- function(a, b, categories) {
  k <- length(categories)
  observed <- table(factor(a, levels = categories), factor(b, levels = categories)) / length(a)
  expected <- outer(rowSums(observed), colSums(observed))
  weights <- outer(seq_len(k), seq_len(k), function(i, j) (i - j)^2 / (k - 1)^2)
  chance <- sum(weights * expected)
  if (chance == 0) return(NA_real_)
  1 - sum(weights * observed) / chance
}

agreement_summary <- function(a, b, categories) {
  data.frame(
    n = length(a),
    exact_agreement = mean(a == b),
    weighted_kappa = weighted_kappa(a, b, categories),
    mean_difference_a_minus_b = mean(a - b),
    two_level_disagreements = sum(abs(a - b) == 2)
  )
}

check_scorer_agreement_file <- function(path, root = NULL) {
  if (is.null(root)) root <- normalizePath(".", winslash = "/", mustWork = TRUE)
  loader <- new.env(parent = globalenv())
  sys.source(file.path(root, "R", "items", "load_items.R"), envir = loader)
  spec <- loader$bii_spec(root)
  if (!file.exists(path)) stop("File della doppia correzione non trovato: ", path, call. = FALSE)

  rows <- utils::read.csv(
    path, stringsAsFactors = FALSE, check.names = FALSE, colClasses = "character",
    na.strings = c("", "NA"), strip.white = TRUE, encoding = "UTF-8"
  )
  missing <- setdiff(agreement_columns, names(rows))
  if (length(missing)) stop("Colonne mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  if (!nrow(rows)) return(invisible(NULL))

  open_ids <- loader$open_response_subtests(spec)
  banks <- lapply(stats::setNames(open_ids, open_ids), function(id) loader$load_item_bank(id, root, spec))

  problems <- character()
  # La riga 1 del file e l'intestazione: la prima risposta e la riga 2.
  add_problem <- function(i, message) problems <<- c(problems, sprintf("riga %d: %s", i + 1L, message))
  blank <- function(x) is.na(x) | !nzchar(x)

  for (i in seq_len(nrow(rows))) {
    row <- rows[i, , drop = FALSE]
    if (blank(row$subject_id)) add_problem(i, "subject_id mancante.")
    if (blank(row$subtest) || !row$subtest %in% open_ids) {
      add_problem(i, paste0(
        "subtest ", if (blank(row$subtest)) "(vuoto)" else row$subtest,
        " non ha una rubrica aperta 0/1/2; ammessi: ", paste(open_ids, collapse = ", "), "."
      ))
      next
    }
    bank <- banks[[row$subtest]]
    if (blank(row$item_id) || !row$item_id %in% bank$items$item_id) {
      practice <- !blank(row$item_id) && row$item_id %in% bank$practice$item_id
      add_problem(i, paste0(
        if (blank(row$item_id)) "item_id mancante" else row$item_id,
        if (practice) ": e un item di prova, che non entra nel punteggio." else
          paste0(": non e un item scored di ", row$subtest, ".")
      ))
    }
    if (blank(row$response)) add_problem(i, "response vuota: trascrivere la risposta corretta dai due correttori.")
    allowed <- as.character(unlist(bank$spec$scoring$item_scores, use.names = FALSE))
    for (column in c("score_a", "score_b")) {
      if (blank(row[[column]])) {
        add_problem(i, paste0(column, " mancante: ogni risposta va corretta da entrambi."))
      } else if (!row[[column]] %in% allowed) {
        add_problem(i, paste0(column, " = ", row[[column]], " non ammesso; valori: ", paste(allowed, collapse = ", "), "."))
      }
    }
  }

  key <- paste(rows$subject_id, rows$item_id, sep = "::")
  for (i in which(duplicated(key) & !blank(rows$subject_id) & !blank(rows$item_id))) {
    add_problem(i, sprintf("stesso subject_id e item_id della riga %d.", match(key[i], key) + 1L))
  }

  if (length(problems)) {
    line_numbers <- as.integer(sub("^riga ([0-9]+):.*$", "\\1", problems))
    problems <- problems[order(line_numbers)]
    stop(
      "Doppia correzione non valida (", length(problems), " problemi):\n  ",
      paste(problems, collapse = "\n  "), call. = FALSE
    )
  }

  rows$score_a <- as.numeric(rows$score_a)
  rows$score_b <- as.numeric(rows$score_b)
  by_subtest <- do.call(rbind, lapply(intersect(open_ids, rows$subtest), function(id) {
    x <- rows[rows$subtest == id, ]
    categories <- as.numeric(unlist(banks[[id]]$spec$scoring$item_scores, use.names = FALSE))
    cbind(subtest = id, agreement_summary(x$score_a, x$score_b, categories))
  }))
  # Item nell'ordine di somministrazione, cosi il report si legge come il modulo.
  item_order <- unlist(lapply(open_ids, function(id) banks[[id]]$items$item_id), use.names = FALSE)
  by_item <- do.call(rbind, lapply(intersect(item_order, rows$item_id), function(item) {
    x <- rows[rows$item_id == item, ]
    data.frame(
      subtest = x$subtest[1], item_id = item, n = nrow(x),
      exact_agreement = mean(x$score_a == x$score_b),
      mean_difference_a_minus_b = mean(x$score_a - x$score_b),
      two_level_disagreements = sum(abs(x$score_a - x$score_b) == 2)
    )
  }))
  two_level <- rows[abs(rows$score_a - rows$score_b) == 2, agreement_columns]
  invisible(list(by_subtest = by_subtest, by_item = by_item, two_level = two_level))
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 1L) stop("Uso: Rscript R/data/check_scorer_agreement.R percorso/al/file.csv")
  result <- check_scorer_agreement_file(args[[1]], root = normalizePath(".", winslash = "/", mustWork = TRUE))
  if (is.null(result)) {
    cat("File valido ma vuoto: nessuna risposta da confrontare.\n")
  } else {
    cat("Accordo per subtest\n")
    print(result$by_subtest, row.names = FALSE, digits = 3)
    cat("\nAccordo per item (ordine di somministrazione)\n")
    print(result$by_item, row.names = FALSE, digits = 3)
    if (nrow(result$two_level)) {
      cat("\nDisaccordi di due livelli (2 contro 0): da discutere per primi\n")
      print(result$two_level, row.names = FALSE)
    }
    small <- result$by_subtest$subtest[result$by_subtest$n < 30]
    if (length(small)) {
      cat("\nAttenzione: meno di 30 risposte per ", paste(small, collapse = ", "),
          ". Con pochi casi il kappa e molto instabile.\n", sep = "")
    }
    cat("Nessuna soglia e applicata: i valori servono a rivedere rubriche e formazione, non a validarle.\n")
  }
}
