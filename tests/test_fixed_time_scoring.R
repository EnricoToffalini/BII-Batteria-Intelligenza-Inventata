source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)
source(file.path(root, "R", "build", "build_record_forms.R"), local = TRUE)

expect_error <- function(expr, pattern = NULL) {
  attempt <- try(expr, silent = TRUE)
  stopifnot(inherits(attempt, "try-error"))
  if (!is.null(pattern)) {
    stopifnot(grepl(pattern, conditionMessage(attr(attempt, "condition")), fixed = TRUE))
  }
  invisible(attempt)
}

# --- routing fixed_time: nessun item fittizio --------------------------------

stopifnot("fixed_time" %in% names(BII_ROUTE_HANDLERS))
for (id in c("CL", "SS")) {
  routed <- route_subtest(id, age_months = 120, root = root)
  stopifnot(
    nrow(routed) == 1L,
    identical(routed$route_type, "fixed_time"),
    identical(routed$termination, "time"),
    is.na(attr(routed, "start_item")),
    !isTRUE(attr(routed, "inversion_applied")),
    is.na(attr(routed, "basal_start")),
    is.na(attr(routed, "ceiling_item"))
  )
}
expect_error(route_subtest("CL", age_months = 60, root = root), "fuori dal range")
expect_error(route_subtest("CL", 1:100, age_months = 120, root = root), "non accetta complete_scores")

# --- CL: corrette - errori, con componenti aggregate -------------------------

cl_record <- data.frame(
  subtest = "CL", correct = 80, errors = 5, omissions = 15,
  actual_time_minutes = 2, procedure_notes = "", stringsAsFactors = FALSE
)
cl <- score_fixed_time_record("CL", cl_record, root)
stopifnot(
  cl$raw_score == 75, cl$valid, length(cl$warnings) == 0L,
  as.numeric(cl$expected_timing$fixed_minutes) == 2
)

cl_negative <- cl_record
cl_negative$correct <- 0
cl_negative$errors <- 10
cl_negative$omissions <- 90
stopifnot(score_fixed_time_record("CL", cl_negative, root)$raw_score == 0)

cl_max <- cl_record
cl_max$correct <- 100
cl_max$errors <- 0
cl_max$omissions <- 0
stopifnot(score_fixed_time_record("CL", cl_max, root)$raw_score == 100)

cl_out_of_range <- cl_record
cl_out_of_range$correct <- 101
expect_error(score_fixed_time_record("CL", cl_out_of_range, root), "fuori range")

cl_fractional <- cl_record
cl_fractional$errors <- 1.5
expect_error(score_fixed_time_record("CL", cl_fractional, root), "deve essere un intero")

cl_impossible <- cl_record
cl_impossible$omissions <- 16
expect_error(score_fixed_time_record("CL", cl_impossible, root), "combinazione impossibile")

cl_missing <- cl_record
cl_missing$correct <- NA
expect_error(score_fixed_time_record("CL", cl_missing, root), "intero non mancante")

cl_missing_column <- cl_record[names(cl_record) != "errors"]
expect_error(score_fixed_time_record("CL", cl_missing_column, root), "Colonne mancanti: errors")

cl_no_time <- cl_record[names(cl_record) != "actual_time_minutes"]
cl_no_time_scored <- score_fixed_time_record("CL", cl_no_time, root)
stopifnot(
  cl_no_time_scored$raw_score == 75,
  any(grepl("non registrato", cl_no_time_scored$warnings))
)

cl_wrong_time <- cl_record
cl_wrong_time$actual_time_minutes <- 2.5
cl_wrong_time_scored <- score_fixed_time_record("CL", cl_wrong_time, root)
stopifnot(
  cl_wrong_time_scored$raw_score == 75,
  any(grepl("limite fisso", cl_wrong_time_scored$warnings))
)

# --- SS: hit - falsi allarmi; planned_minutes non diventa un limite ----------

ss_record <- data.frame(
  subtest = "SS", hits = 70, false_alarms = 10, omissions = 30,
  actual_time_minutes = 2.5, procedure_notes = "", stringsAsFactors = FALSE
)
ss <- score_fixed_time_record("SS", ss_record, root)
stopifnot(
  ss$raw_score == 60, ss$valid, length(ss$warnings) == 0L,
  identical(as.numeric(unlist(ss$expected_timing$planned_minutes)), c(2, 3))
)

ss_negative <- ss_record
ss_negative$hits <- 5
ss_negative$false_alarms <- 10
stopifnot(score_fixed_time_record("SS", ss_negative, root)$raw_score == 0)

ss_out_of_range <- ss_record
ss_out_of_range$false_alarms <- 101
expect_error(score_fixed_time_record("SS", ss_out_of_range, root), "fuori range")

ss_no_time <- ss_record[names(ss_record) != "actual_time_minutes"]
ss_no_time_scored <- score_fixed_time_record("SS", ss_no_time, root)
stopifnot(
  ss_no_time_scored$raw_score == 60,
  any(grepl("non registrato", ss_no_time_scored$warnings))
)

ss_outside_plan <- ss_record
ss_outside_plan$actual_time_minutes <- 4
ss_outside_plan_scored <- score_fixed_time_record("SS", ss_outside_plan, root)
stopifnot(
  ss_outside_plan_scored$raw_score == 60,
  any(grepl("durata pianificata", ss_outside_plan_scored$warnings)),
  any(grepl("non dichiara un limite fisso", ss_outside_plan_scored$warnings))
)

# --- moduli aggregati derivati dalla spec ------------------------------------

for (id in c("CL", "SS")) {
  st <- bii_spec(root)$subtests[[id]]
  form <- utils::read.csv(
    record_form_path(id, root), stringsAsFactors = FALSE, check.names = FALSE
  )
  stopifnot(
    nrow(form) == 1L,
    identical(form$subtest, id),
    all(names(st$scoring$components) %in% names(form)),
    all(c("actual_time_minutes", "procedure_notes") %in% names(form)),
    !any(c("item_id", "item_score", "administration_status") %in% names(form))
  )
}

# --- regressione: gli handler preesistenti restano invariati -----------------

regression_cases <- list(SP = 2, RS = 1, CR = 2, PG = 1, SM = 1)
for (id in names(regression_cases)) {
  context <- load_item_bank(id, root)
  routed <- route_subtest(
    id, rep(regression_cases[[id]], nrow(context$items)),
    age_months = 120, root = root
  )
  stopifnot(
    nrow(routed) == nrow(context$items),
    sum(routed$assigned_score) == as.numeric(context$spec$scoring$raw_max)
  )
}
