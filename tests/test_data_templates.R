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
  item_score = 2, response_time_seconds = 5, notes = "",
  stringsAsFactors = FALSE
)
valid_path <- tempfile(fileext = ".csv")
utils::write.csv(valid_row, valid_path, row.names = FALSE, na = "")
stopifnot(nrow(check_response_file(valid_path, root = root)) == 1L)
