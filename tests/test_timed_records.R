source(file.path(root, "R", "data", "check_timed_records.R"), local = TRUE)

expect_error <- function(expr, pattern = NULL) {
  attempt <- try(expr, silent = TRUE)
  stopifnot(inherits(attempt, "try-error"))
  if (!is.null(pattern)) {
    stopifnot(grepl(pattern, conditionMessage(attr(attempt, "condition")), fixed = TRUE))
  }
  invisible(attempt)
}

write_timed <- function(rows) {
  path <- tempfile(fileext = ".csv")
  utils::write.csv(rows, path, row.names = FALSE, na = "")
  path
}

spec <- bii_timed_engine(root)$bii_spec(root)

# --- modello e colonne derivati dalla spec -----------------------------------

template_path <- file.path(root, "data", "templates", "timed_records.csv")
template <- utils::read.csv(template_path, stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(
  identical(names(template), timed_record_columns(spec)),
  nrow(template) == 0L,
  nrow(check_timed_record_file(template_path, root = root)) == 0L
)
# Ogni prova fixed_time della spec, e soltanto quelle, e coperta dal modello.
stopifnot(identical(timed_subtest_ids(spec), c("CL", "SS")))

# Un record compilato con le stesse colonne del modulo di registrazione di un
# solo subtest e accettato: non servono le colonne dell'altra prova.
for (id in timed_subtest_ids(spec)) {
  form <- utils::read.csv(
    file.path(root, "materials", "record_forms", paste0(id, "_record_form.csv")),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  stopifnot(all(names(form) %in% timed_record_columns(spec)))
}

# --- file valido --------------------------------------------------------------

valid <- data.frame(
  subject_id = c("P001", "P001", "P002", "P002"),
  age_months = c(120, 120, 200, 200),
  subtest = c("CL", "SS", "CL", "SS"),
  correct = c(80, NA, 100, NA),
  errors = c(5, NA, 0, NA),
  omissions = c(15, 30, 0, 0),
  hits = c(NA, 70, NA, 100),
  false_alarms = c(NA, 10, NA, 0),
  actual_time_minutes = c(2, 2.5, NA, 4),
  procedure_notes = c("", "", "cronometro non registrato", ""),
  stringsAsFactors = FALSE
)
checked <- check_timed_record_file(write_timed(valid), root = root)
stopifnot(
  identical(checked$raw_score, c(75, 60, 100, 100)),
  identical(nzchar(checked$warnings), c(FALSE, FALSE, TRUE, TRUE)),
  grepl("non registrato", checked$warnings[3]),
  grepl("durata pianificata", checked$warnings[4])
)

# Formato di un modulo di registrazione di un solo subtest.
cl_only <- valid[valid$subtest == "CL", c("subject_id", "age_months", "subtest", "correct", "errors", "omissions", "actual_time_minutes", "procedure_notes")]
stopifnot(identical(check_timed_record_file(write_timed(cl_only), root = root)$raw_score, c(75, 100)))

# --- vincolo SS dalla composizione: hits + omissions <= target_count ----------

target_count <- as.numeric(spec$subtests$SS$stimulus_composition$target_count)
ss_boundary <- valid[2, ]
ss_boundary$hits <- target_count - 20
ss_boundary$omissions <- 20
stopifnot(check_timed_record_file(write_timed(ss_boundary), root = root)$raw_score == target_count - 30)
ss_impossible <- ss_boundary
ss_impossible$omissions <- 21
expect_error(check_timed_record_file(write_timed(ss_impossible), root = root), "hits + omissions supera")

# --- errori, con numero di riga del file -------------------------------------

check_invalid <- function(rows, pattern) {
  expect_error(check_timed_record_file(write_timed(rows), root = root), pattern)
}

bad <- valid
bad$subject_id[2] <- ""
check_invalid(bad, "riga 3: subject_id mancante")

bad <- valid
bad$subtest[1] <- "XX"
check_invalid(bad, "riga 2: subtest sconosciuto: XX")

bad <- valid
bad$subtest[1] <- "SP"
check_invalid(bad, "SP non e una prova a tempo")

bad <- valid
bad$age_months[1] <- 60
check_invalid(bad, "riga 2: CL: eta 60 mesi fuori dal range")

bad <- valid
bad$age_months <- as.character(bad$age_months)
bad$age_months[1] <- "120.5"
check_invalid(bad, "age_months deve essere un numero intero")

bad <- valid
bad$correct[1] <- 81
check_invalid(bad, "riga 2: CL: combinazione impossibile")

bad <- valid
bad$errors[1] <- NA
check_invalid(bad, "CL: errors deve essere un intero non mancante")

bad <- valid
bad$false_alarms[2] <- 101
check_invalid(bad, "riga 3: SS: false_alarms fuori range")

bad <- valid
bad$hits[1] <- 3
check_invalid(bad, "colonne non previste per CL compilate: hits")

bad <- valid
bad$actual_time_minutes <- as.character(bad$actual_time_minutes)
bad$actual_time_minutes[1] <- "due"
check_invalid(bad, "actual_time_minutes deve essere un numero positivo")

bad <- valid
bad$actual_time_minutes[1] <- 0
check_invalid(bad, "actual_time_minutes deve essere un numero positivo")

bad <- rbind(valid, valid[1, ])
check_invalid(bad, "riga 6: stesso subject_id e subtest della riga 2")

# Tutti i problemi vengono riportati insieme, in ordine di file.
bad <- valid
bad$subtest[4] <- "XX"
bad$subject_id[1] <- ""
attempt <- expect_error(check_timed_record_file(write_timed(bad), root = root), "2 problemi")
message_text <- conditionMessage(attr(attempt, "condition"))
stopifnot(regexpr("riga 2:", message_text) < regexpr("riga 5:", message_text))

# Colonne strutturali mancanti: errore immediato, non una lista per riga.
check_invalid(valid[names(valid) != "actual_time_minutes"], "Colonne mancanti: actual_time_minutes")
check_invalid(valid[names(valid) != "false_alarms"], "Colonne mancanti: false_alarms")

# --- la spec rifiuta vincoli malformati --------------------------------------

spec_env <- new.env(parent = baseenv())
sys.source(file.path(root, "R", "spec", "load_spec.R"), envir = spec_env)
mutated <- spec
mutated$subtests$SS$scoring$constraints[[1]]$max_from <- "stimulus_count"
expect_error(spec_env$validate_bii_spec(mutated), "max_from non supportato")
mutated <- spec
mutated$subtests$SS$scoring$constraints[[1]]$components <- list("hits", "misses")
expect_error(spec_env$validate_bii_spec(mutated), "componenti mancanti, duplicate o sconosciute")
mutated <- spec
mutated$subtests$SS$scoring$constraints[[1]]$max <- 100
expect_error(spec_env$validate_bii_spec(mutated), "esattamente uno fra max e max_from")
