source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)

rr <- load_item_bank("RR", root)
items <- rr$items
stopifnot(nrow(items) == 20L, nrow(rr$practice) == 2L)

# I controlli di qualita comuni ai banchi a scelta multipla stanno in
# tests/test_multiple_choice_banks.R. Qui restano routing, scoring e le
# proprieta specifiche di RR.

# --- proprieta specifiche di RR ------------------------------------------------

# RR inverte un item alla volta, come SP e a differenza di RS: e la differenza
# che il manuale dichiara e che l'esaminatore deve applicare.
stopifnot(identical(rr$spec$administration$inversion$direction, "backward"))

# L'opzione "non si puo sapere" e corretta una volta sola, ma compare piu volte:
# se comparisse solo dove e corretta sarebbe un indizio.
appears <- rowSums(
  vapply(
    c("option_a", "option_b", "option_c", "option_d"),
    function(col) grepl("non si pu", items[[col]]),
    logical(nrow(items))
  )
)
is_correct_unknown <- grepl("non si pu", items$scoring_key)
stopifnot(sum(appears > 0) >= 3L, sum(is_correct_unknown) == 1L)

# I condizionali non compaiono nelle prime posizioni: alla partenza dei piu
# piccoli misurerebbero la comprensione della consegna.
conditional_positions <- items$order[items$family == "conditional_rule"]
stopifnot(length(conditional_positions) > 0L, min(conditional_positions) >= 7L)

# --- routing e scoring ---------------------------------------------------------

# Sette anni: start all'item 1, nessuna inversione possibile.
child <- route_subtest("RR", c(rep(1, 5), rep(0, 15)), age_months = 84, root = root)
stopifnot(
  identical(attr(child, "start_item"), 1L),
  identical(attr(child, "ceiling_item"), 8L),
  all(child$administration_status[1:8] == "administered"),
  all(child$administration_status[9:20] == "above_ceiling"),
  sum(child$assigned_score) == 5
)

# Sedicenne: start all'item 7. Una sola risposta corretta nella finestra
# iniziale, quindi inversione un item alla volta fino al basale 3-4-5.
teen_scores <- rep(0, 20)
teen_scores[3:5] <- 1
teen_scores[7] <- 1
teen <- route_subtest("RR", teen_scores, age_months = 200, root = root)
stopifnot(
  identical(attr(teen, "start_item"), 7L),
  isTRUE(attr(teen, "inversion_applied")),
  identical(attr(teen, "basal_start"), 3L),
  all(teen$administration_status[1:2] == "below_basal"),
  # l'inversione item per item non presenta nulla sotto il basale trovato
  length(attr(teen, "presented_below_basal")) == 0L,
  identical(attr(teen, "ceiling_item"), 10L)
)
# Punteggio calcolato a mano: 2 item sotto basale + i corretti fra 3 e 10.
stopifnot(sum(teen$assigned_score) == 2 * 1 + sum(teen_scores[3:10]))

# Ventunenne che risponde a tutto: nessuna inversione, credito pieno sotto il
# punto di partenza, punteggio grezzo al massimo dichiarato dalla spec.
top <- route_subtest("RR", rep(1, 20), age_months = 260, root = root)
stopifnot(
  !isTRUE(attr(top, "inversion_applied")),
  all(top$administration_status[1:6] == "below_basal"),
  sum(top$assigned_score) == rr$spec$scoring$raw_max
)

# --- record ---------------------------------------------------------------------

record <- data.frame(
  item_id = teen$item_id,
  administration_status = teen$administration_status,
  item_score = teen$observed_score,
  stringsAsFactors = FALSE
)
scored <- score_subtest_record("RR", record, root)
stopifnot(scored$valid, scored$raw_score == sum(teen$assigned_score), scored$raw_max == 20)

record$administration_status[5] <- "invalidated"
record$item_score[5] <- NA
invalidated <- score_subtest_record("RR", record, root)
stopifnot(!invalidated$valid, is.na(invalidated$raw_score))

# --- modulo di registrazione ------------------------------------------------------

form <- utils::read.csv(
  file.path(root, "materials", "record_forms", "RR_record_form.csv"),
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(identical(form[form$item_type == "scored", "item_id"], items$item_id))
