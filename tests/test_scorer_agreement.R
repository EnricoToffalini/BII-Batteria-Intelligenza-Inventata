source(file.path(root, "R", "data", "check_scorer_agreement.R"), local = TRUE)

expect_error <- function(expr, pattern) {
  attempt <- try(expr, silent = TRUE)
  stopifnot(inherits(attempt, "try-error"))
  stopifnot(grepl(pattern, conditionMessage(attr(attempt, "condition")), fixed = TRUE))
  invisible(attempt)
}

write_rows <- function(rows) {
  path <- tempfile(fileext = ".csv")
  utils::write.csv(rows, path, row.names = FALSE, na = "")
  path
}

near <- function(x, y) isTRUE(all.equal(x, y, tolerance = 1e-12))

# --- modello ------------------------------------------------------------------

template_path <- file.path(root, "data", "templates", "scorer_agreement.csv")
template <- utils::read.csv(template_path, stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(
  identical(names(template), agreement_columns),
  nrow(template) == 0L,
  is.null(check_scorer_agreement_file(template_path, root = root))
)

# --- valori calcolati a mano --------------------------------------------------
# SP, sei coppie (A, B): (2,2) (2,1) (1,1) (0,0) (0,2) (1,1).
# Accordo esatto 4/6. Pesi quadratici: 0.25 per un livello, 1 per due.
# Disaccordo osservato pesato: (0.25 + 1) / 6 = 0.208333.
# Marginali A = (1/3, 1/3, 1/3), B = (1/6, 1/2, 1/3) per 0, 1, 2; disaccordo
# atteso pesato = 1/3 * (0.458333 + 0.125 + 0.291667) = 0.291667.
# Kappa = 1 - 0.208333 / 0.291667 = 2/7. Differenza media A - B = (6 - 7) / 6.
# CS: due coppie (1,1): accordo perfetto ma kappa non definito.

valid <- data.frame(
  subject_id = c("P001", "P001", "P001", "P002", "P002", "P002", "P001", "P002"),
  subtest = c("SP", "SP", "SP", "SP", "SP", "SP", "CS", "CS"),
  item_id = c("SP-SC-02", "SP-SC-01", "SP-SC-05", "SP-SC-01", "SP-SC-05", "SP-SC-02", "CS-SC-01", "CS-SC-01"),
  response = c("attento ai pericoli", "affaticato", "non arrendersi", "boh", "fare forza", "attento",
               "lo cerco", "lo dico alla maestra"),
  score_a = c(1, 2, 2, 0, 0, 1, 1, 1),
  score_b = c(1, 2, 1, 0, 2, 1, 1, 1),
  stringsAsFactors = FALSE
)
result <- check_scorer_agreement_file(write_rows(valid), root = root)

sp <- result$by_subtest[result$by_subtest$subtest == "SP", ]
cs <- result$by_subtest[result$by_subtest$subtest == "CS", ]
stopifnot(
  identical(result$by_subtest$subtest, c("SP", "CS")),
  sp$n == 6L,
  near(sp$exact_agreement, 4 / 6),
  near(sp$weighted_kappa, 2 / 7),
  near(sp$mean_difference_a_minus_b, -1 / 6),
  sp$two_level_disagreements == 1L,
  cs$exact_agreement == 1,
  is.na(cs$weighted_kappa)
)

# Item nell'ordine di somministrazione SP (01, 05, 02), non nell'ordine del file.
stopifnot(
  identical(result$by_item$item_id, c("SP-SC-01", "SP-SC-05", "SP-SC-02", "CS-SC-01")),
  near(result$by_item$mean_difference_a_minus_b[2], -0.5),
  result$by_item$two_level_disagreements[2] == 1L,
  identical(result$two_level$response, "fare forza")
)

# Il kappa e simmetrico rispetto ai correttori; la differenza media cambia segno.
swapped <- valid
swapped[c("score_a", "score_b")] <- valid[c("score_b", "score_a")]
swapped_result <- check_scorer_agreement_file(write_rows(swapped), root = root)
stopifnot(
  near(swapped_result$by_subtest$weighted_kappa[1], 2 / 7),
  near(swapped_result$by_subtest$mean_difference_a_minus_b[1], 1 / 6)
)

# --- file non validi: tutti i problemi, con il numero di riga ------------------

invalid <- data.frame(
  subject_id = c("P001", "P001", "P001", "P001", "P001", "P001", "P001"),
  subtest = c("RS", "SP", "SP", "SP", "SP", "SP", "SP"),
  item_id = c("RS-SC-01", "SP-PR-01", "CS-SC-01", "SP-SC-01", "SP-SC-01", "SP-SC-03", "SP-SC-04"),
  response = c("b", "un vetro", "lo cerco", "stanco", "stanco", "", "non chiaro"),
  score_a = c("1", "2", "1", "3", "2", "1", "1"),
  score_b = c("1", "2", "1", "2", "2", "1", ""),
  stringsAsFactors = FALSE
)
message_text <- conditionMessage(attr(try(check_scorer_agreement_file(write_rows(invalid), root = root), silent = TRUE), "condition"))
for (expected in c(
  "riga 2: subtest RS non ha una rubrica aperta 0/1/2",
  "riga 3: SP-PR-01: e un item di prova",
  "riga 4: CS-SC-01: non e un item scored di SP",
  "riga 5: score_a = 3 non ammesso",
  "riga 6: stesso subject_id e item_id della riga 5",
  "riga 7: response vuota",
  "riga 8: score_b mancante"
)) {
  if (!grepl(expected, message_text, fixed = TRUE)) stop("Problema non riportato: ", expected)
}

expect_error(
  check_scorer_agreement_file(write_rows(valid[, setdiff(names(valid), "score_b")]), root = root),
  "Colonne mancanti: score_b"
)
