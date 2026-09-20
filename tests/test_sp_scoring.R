source(file.path(root, "R", "scoring", "SP.R"), local = TRUE)

# Un quattordicenne parte dall'item 7. Con tutte risposte piene non inverte.
high <- route_sp(rep(2, 18), age_months = 168, root = root)
stopifnot(
  identical(attr(high, "start_item"), 7L),
  !isTRUE(attr(high, "inversion_applied")),
  all(high$administration_status[1:6] == "below_basal"),
  all(high$administration_status[7:18] == "administered"),
  sum(high$assigned_score) == 36
)

# Con tutte risposte errate si torna fino all'item 1 e poi si arresta alla
# terza risposta zero della finestra iniziale. Il ceiling non opera a ritroso.
low <- route_sp(rep(0, 18), age_months = 168, root = root)
stopifnot(
  isTRUE(attr(low, "inversion_applied")),
  is.na(attr(low, "basal_start")),
  identical(attr(low, "ceiling_item"), 9L),
  all(low$administration_status[1:9] == "administered"),
  all(low$administration_status[10:18] == "above_ceiling"),
  sum(low$assigned_score) == 0
)

# Caso di inversione con basal raggiunto agli item 5-7.
basal_scores <- rep(1, 18)
basal_scores[5:7] <- 2
basal_scores[8] <- 0
basal <- route_sp(basal_scores, age_months = 168, root = root)
stopifnot(
  isTRUE(attr(basal, "inversion_applied")),
  identical(attr(basal, "basal_start"), 5L),
  all(basal$administration_status[1:4] == "below_basal")
)

# Lo scorer conserva gli stati: sotto basal vale 2, omissione vale 0;
# missing esterno e invalidazione non vengono trasformati in errori.
record <- data.frame(
  item_id = high$item_id,
  administration_status = high$administration_status,
  item_score = high$observed_score,
  stringsAsFactors = FALSE
)
scored <- score_sp_record(record, root)
stopifnot(scored$valid, scored$raw_score == 36)

record$administration_status[7] <- "omitted"
record$item_score[7] <- NA
omitted <- score_sp_record(record, root)
stopifnot(omitted$valid, omitted$raw_score == 34)

record$administration_status[8] <- "external_missing"
record$item_score[8] <- NA
missing <- score_sp_record(record, root)
stopifnot(!missing$valid, is.na(missing$raw_score))

# Il modulo per studenti deve seguire gli stessi ID e lo stesso ordine.
form <- utils::read.csv(
  file.path(root, "materials", "record_forms", "SP_record_form.csv"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)
form_scored <- form[form$item_type == "scored", ]
stopifnot(identical(form_scored$item_id, high$item_id))
