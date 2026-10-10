source(file.path(root, "R", "data", "score_collected.R"), local = TRUE)

loader <- new.env(parent = globalenv())
sys.source(file.path(root, "R", "items", "load_items.R"), envir = loader)
sp_items <- loader$load_item_bank("SP", root)$items$item_id

template <- utils::read.csv(file.path(root, "data", "templates", "responses.csv"), check.names = FALSE)

write_csv <- function(rows) {
  path <- tempfile(fileext = ".csv")
  utils::write.csv(rows, path, row.names = FALSE, na = "")
  path
}

sp_record <- function(subject_id, age, status, score) {
  rows <- as.data.frame(matrix(NA, nrow = length(status), ncol = ncol(template), dimnames = list(NULL, names(template))))
  rows$subject_id <- subject_id
  rows$age_months <- age
  rows$subtest <- "SP"
  rows$item_id <- sp_items[seq_along(status)]
  rows$administration_status <- status
  rows$item_score <- score
  rows
}

# P001, 16;8 (200 mesi), parte dall'item 7. Item 7-9: 2+2+2, nessuna
# inversione, quindi item 1-6 inferiti a 2 punti (12). Avanti: item 10-14 =
# 2, 1, 0, 0, 0; interruzione dopo tre zeri, item 15-18 sopra ceiling.
# Grezzo calcolato a mano: 12 + 6 + 2 + 1 = 21.
p001 <- sp_record(
  "P001", 200,
  status = c(rep("below_basal", 6), rep("administered", 8), rep("above_ceiling", 4)),
  score = c(rep(NA, 6), 2, 2, 2, 2, 1, 0, 0, 0, rep(NA, 4))
)
# P002: stesso protocollo, ma l'item 12 non è stato somministrato per un
# motivo esterno. Il totale non si calcola e non diventa un errore.
p002 <- p001
p002$subject_id <- "P002"
p002$administration_status[12] <- "external_missing"
p002$item_score[12] <- NA
# P003: protocollo con tre sole righe, non correggibile.
p003 <- sp_record("P003", 100, status = rep("administered", 3), score = c(2, 2, 2))

responses_path <- write_csv(rbind(p003, p002, p001))
timed_path <- write_csv(data.frame(
  subject_id = "P001", age_months = 200, subtest = "CL",
  correct = 80, errors = 5, omissions = 15, hits = NA, false_alarms = NA,
  actual_time_minutes = 2, procedure_notes = ""
))

result <- score_collected(responses_path, timed_path, root = root)
stopifnot(
  identical(names(result), raw_score_columns),
  # Ordine: persona, poi subtest nell'ordine della batteria (SP prima di CL).
  identical(paste(result$subject_id, result$subtest), c("P001 SP", "P001 CL", "P002 SP", "P003 SP")),
  identical(result$raw_score, c(21, 75, NA, NA)),
  identical(result$status, c("complete", "complete", "external_missing_or_invalidated", "incomplete_record")),
  grepl("item scored", result$notes[4]),
  all(result$raw_max[result$subtest == "SP"] == 36)
)

# Un file non valido si ferma al controllo, prima dello scoring.
broken <- p001
broken$item_score[7] <- 3
attempt <- try(score_collected(write_csv(broken), root = root), silent = TRUE)
stopifnot(inherits(attempt, "try-error"), grepl("item_score", conditionMessage(attr(attempt, "condition"))))

# Il modello vuoto produce una tabella vuota con le colonne attese.
empty <- score_collected(file.path(root, "data", "templates", "responses.csv"), root = root)
stopifnot(nrow(empty) == 0L, identical(names(empty), raw_score_columns))
