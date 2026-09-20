source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)

rs <- load_item_bank("RS", root)
items <- rs$items
stopifnot(nrow(items) == 24L, nrow(rs$practice) == 2L)

# I controlli di qualita comuni ai banchi a scelta multipla stanno in
# tests/test_multiple_choice_banks.R. Qui restano solo routing e scoring.

# --- routing e scoring --------------------------------------------------------

# Bambino di 7 anni: start all'item 1, nessuna inversione possibile.
child <- route_subtest("RS", c(rep(1, 6), rep(0, 18)), age_months = 84, root = root)
stopifnot(
  identical(attr(child, "start_item"), 1L),
  is.na(attr(child, "basal_start")),
  identical(attr(child, "ceiling_item"), 9L),
  all(child$administration_status[1:9] == "administered"),
  all(child$administration_status[10:24] == "above_ceiling"),
  sum(child$assigned_score) == 6
)

# Undicenne: start all'item 5. Con due risposte corrette nella finestra
# iniziale non si inverte e gli item 1-4 ricevono un punto inferito.
teen_scores <- rep(0, 24)
teen_scores[c(5, 6, 8, 9)] <- 1
teen <- route_subtest("RS", teen_scores, age_months = 132, root = root)
stopifnot(
  identical(attr(teen, "start_item"), 5L),
  !isTRUE(attr(teen, "inversion_applied")),
  all(teen$administration_status[1:4] == "below_basal"),
  identical(attr(teen, "ceiling_item"), 12L),
  sum(teen$assigned_score) == 4 + 4
)

# --- scoring del record: gli stati non diventano errori -----------------------

record <- data.frame(
  item_id = teen$item_id,
  administration_status = teen$administration_status,
  item_score = teen$observed_score,
  stringsAsFactors = FALSE
)
scored <- score_subtest_record("RS", record, root)
stopifnot(scored$valid, scored$raw_score == 8, scored$raw_max == 24, length(scored$warnings) == 0L)

record$administration_status[7] <- "omitted"
record$item_score[7] <- NA
omitted <- score_subtest_record("RS", record, root)
stopifnot(omitted$valid, omitted$raw_score == 8)

record$administration_status[9] <- "external_missing"
record$item_score[9] <- NA
external <- score_subtest_record("RS", record, root)
stopifnot(
  !external$valid,
  is.na(external$raw_score),
  external$reason == "external_missing_or_invalidated"
)

# Un record che ignora la regola di interruzione deve produrre un avviso
# procedurale senza rifiutare il calcolo.
sloppy <- data.frame(
  item_id = items$item_id,
  administration_status = "administered",
  item_score = c(rep(1, 4), rep(0, 20)),
  stringsAsFactors = FALSE
)
sloppy_scored <- score_subtest_record("RS", sloppy, root)
stopifnot(
  sloppy_scored$valid,
  sloppy_scored$raw_score == 4,
  any(grepl("interruzione", sloppy_scored$warnings))
)

# --- modulo di registrazione --------------------------------------------------

form <- utils::read.csv(
  file.path(root, "materials", "record_forms", "RS_record_form.csv"),
  stringsAsFactors = FALSE, check.names = FALSE
)
form_scored <- form[form$item_type == "scored", ]
stopifnot(
  identical(form_scored$item_id, items$item_id),
  identical(form[form$item_type == "practice", "item_id"], rs$practice$item_id)
)
