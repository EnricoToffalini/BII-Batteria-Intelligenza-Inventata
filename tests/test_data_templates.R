source(file.path(root, "R", "data", "check_responses.R"), local = TRUE)

participants <- utils::read.csv(file.path(root, "data", "templates", "participants.csv"), stringsAsFactors = FALSE, check.names = FALSE)
responses_path <- file.path(root, "data", "templates", "responses.csv")
responses <- utils::read.csv(responses_path, stringsAsFactors = FALSE, check.names = FALSE)

stopifnot(identical(names(participants), c("subject_id", "age_months", "data_source", "notes")))
stopifnot(identical(names(responses), response_columns))
checked <- check_response_file(responses_path, root = root)
stopifnot(nrow(checked) == 0L)

valid_row <- data.frame(
  subject_id = "P001", age_months = 120, subtest = "SP", item_id = "SP-SC-01",
  administration_status = "administered", response = "Ha bisogno di riposare",
  item_score = 2, recall = NA, recognition = NA, delay_minutes = NA,
  response_time_seconds = 5, notes = "",
  stringsAsFactors = FALSE
)
valid_path <- tempfile(fileext = ".csv")
utils::write.csv(valid_row, valid_path, row.names = FALSE, na = "")
stopifnot(nrow(check_response_file(valid_path, root = root)) == 1L)

wrong_columns <- valid_row
wrong_columns$recall <- "correct"
wrong_path <- tempfile(fileext = ".csv")
utils::write.csv(wrong_columns, wrong_path, row.names = FALSE, na = "")
stopifnot(inherits(try(check_response_file(wrong_path, root = root), silent = TRUE), "try-error"))

# Un protocollo CR completo conserva le componenti osservate e viene passato
# allo scorer reale. Non serve ricostruire item_score a mano.
cr_form <- utils::read.csv(
  file.path(root, "materials", "record_forms", "CR_record_form.csv"),
  stringsAsFactors = FALSE, check.names = FALSE, na.strings = c("", "NA")
)
cr_record <- data.frame(
  subject_id = "P002",
  age_months = 144,
  subtest = "CR",
  item_id = cr_form$item_id,
  administration_status = "administered",
  response = NA,
  item_score = NA,
  recall = "correct",
  recognition = "not_administered",
  delay_minutes = 15,
  response_time_seconds = NA,
  notes = NA,
  stringsAsFactors = FALSE
)
cr_path <- tempfile(fileext = ".csv")
utils::write.csv(cr_record, cr_path, row.names = FALSE, na = "")
stopifnot(nrow(check_response_file(cr_path, root = root)) == nrow(cr_record))

manual_score <- cr_record
manual_score$item_score[1] <- 2
manual_path <- tempfile(fileext = ".csv")
utils::write.csv(manual_score, manual_path, row.names = FALSE, na = "")
stopifnot(inherits(try(check_response_file(manual_path, root = root), silent = TRUE), "try-error"))

# Un richiamo fallito senza il riconoscimento richiesto non supera il checker:
# il dato mancante non viene trasformato in zero.
cr_incomplete <- cr_record
cr_incomplete$recall[1] <- "incorrect"
bad_path <- tempfile(fileext = ".csv")
utils::write.csv(cr_incomplete, bad_path, row.names = FALSE, na = "")
attempt <- try(check_response_file(bad_path, root = root), silent = TRUE)
stopifnot(
  inherits(attempt, "try-error"),
  grepl("CR-SC-01", conditionMessage(attr(attempt, "condition")))
)
