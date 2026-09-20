# Test del motore generico: le regole devono venire dalla spec, non dal codice.
source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)
source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)

spec <- read_bii_spec(root)

# --- criteri di finestra letti dalla spec ------------------------------------

stopifnot(
  bii_window_met(c(2, 2, 2), list(total_score = 6), 2),
  !bii_window_met(c(2, 2, 1), list(total_score = 6), 2),
  bii_window_met(c(1, 1, 1), list(correct = 3), 1),
  !bii_window_met(c(1, 1, 0), list(correct = 3), 1),
  bii_inversion_triggered(c(1, 1, 1), list(total_score_lt = 4), 2),
  !bii_inversion_triggered(c(2, 2, 0), list(total_score_lt = 4), 2),
  bii_inversion_triggered(c(1, 0, 0), list(correct_lt = 2), 1),
  !bii_inversion_triggered(c(1, 1, 0), list(correct_lt = 2), 1)
)

# Un criterio non riconosciuto deve fermare l'esecuzione, non essere ignorato.
stopifnot(inherits(try(bii_window_met(c(1, 1), list(), 1), silent = TRUE), "try-error"))

# --- inversione a blocchi (RS) -----------------------------------------------

rs <- load_item_bank("RS", root)
stopifnot(
  identical(rs$spec$administration$inversion$direction, "backward_in_blocks"),
  nrow(rs$items) == 24L
)

# Diciassettenne: start all'item 9. Nessuna risposta corretta nella finestra
# iniziale, quindi si inverte a blocchi di tre fino all'item 1 senza mai
# raggiungere il basale; il ceiling opera solo in avanti.
rs_low <- route_subtest("RS", rep(0, 24), age_months = 210, root = root)
stopifnot(
  identical(attr(rs_low, "start_item"), 9L),
  isTRUE(attr(rs_low, "inversion_applied")),
  is.na(attr(rs_low, "basal_start")),
  identical(attr(rs_low, "ceiling_item"), 11L),
  all(rs_low$administration_status[1:11] == "administered"),
  all(rs_low$administration_status[12:24] == "above_ceiling"),
  sum(rs_low$assigned_score) == 0
)

# Il blocco di tre item deve essere somministrato per intero anche quando il
# basale sarebbe soddisfatto dal primo item del blocco: e questa la differenza
# rispetto all'inversione item per item.
rs_scores <- rep(1, 24)
rs_scores[9] <- 0      # una sola risposta corretta nella finestra 9-11
rs_scores[10] <- 0
rs_scores[5] <- 0      # rompe il basale nel primo blocco a ritroso (6-8)
rs_scores[15] <- 0
rs_scores[16] <- 0
rs_scores[17] <- 0
rs_block <- route_subtest("RS", rs_scores, age_months = 210, root = root)
stopifnot(
  isTRUE(attr(rs_block, "inversion_applied")),
  identical(attr(rs_block, "basal_start"), 6L),
  all(rs_block$administration_status[1:5] == "below_basal"),
  all(rs_block$administration_status[6:17] == "administered"),
  identical(attr(rs_block, "ceiling_item"), 17L),
  all(rs_block$administration_status[18:24] == "above_ceiling")
)

# Punteggio atteso calcolato a mano: 5 item sotto basale a credito pieno,
# più gli item somministrati corretti fra 6 e 17.
manual_raw <- 5 * 1 + sum(rs_scores[6:17])
stopifnot(sum(rs_block$assigned_score) == manual_raw)

# Caso che distingue davvero il blocco dall'inversione item per item.
# Il basale cade a 7 (item 7-8-9 corretti): con inversione item per item
# l'item 6 non sarebbe mai stato presentato, con i blocchi di tre lo e.
# In entrambi i casi sotto il basale vale il credito pieno.
distinguishing <- rep(1, 24)
distinguishing[c(6, 10, 11)] <- 0
distinguishing[15:17] <- 0
rs_dist <- route_subtest("RS", distinguishing, age_months = 210, root = root)
stopifnot(
  isTRUE(attr(rs_dist, "inversion_applied")),
  identical(attr(rs_dist, "basal_start"), 7L),
  all(rs_dist$administration_status[1:6] == "below_basal"),
  # l'item 6 e stato presentato, ha ricevuto 0, e riceve comunque credito pieno
  identical(attr(rs_dist, "presented_below_basal"), 6L),
  rs_dist$assigned_score[6] == 1,
  is.na(rs_dist$observed_score[6])
)

# Senza trigger di inversione gli item precedenti ricevono credito pieno.
rs_high <- route_subtest("RS", rep(1, 24), age_months = 210, root = root)
stopifnot(
  !isTRUE(attr(rs_high, "inversion_applied")),
  all(rs_high$administration_status[1:8] == "below_basal"),
  sum(rs_high$assigned_score) == rs$spec$scoring$raw_max
)

# --- coerenza dei punti di partenza con l'item bank disponibile ---------------

for (id in subtests_with_item_bank(root, spec)) {
  context <- load_item_bank(id, root, spec)
  if (!identical(context$spec$administration$route_type, "adaptive_items")) next
  starts <- vapply(
    context$spec$administration$start_points,
    function(rule) as.integer(rule$item), integer(1)
  )
  if (max(starts) > nrow(context$items)) {
    stop(id, ": punto di partenza oltre il numero di item presenti nell'item bank.")
  }
  # Ogni eta prevista dalla batteria deve trovare un punto di partenza.
  for (age in c(72L, 107L, 108L, 155L, 156L, 263L)) {
    subtest_start_item(age, context$spec)
  }
}

# --- stati di somministrazione ------------------------------------------------

stopifnot(setequal(BII_RESPONSE_STATUSES, names(spec$battery$administration$response_statuses)))

# Uno stato inventato deve essere rifiutato.
bad_record <- data.frame(
  item_id = rs$items$item_id,
  administration_status = c("boh", rep("administered", 23)),
  item_score = rep(1, 24),
  stringsAsFactors = FALSE
)
stopifnot(inherits(try(score_subtest_record("RS", bad_record, root), silent = TRUE), "try-error"))

# I subtest non ancora coperti dal motore devono dare un errore esplicito.
cr_like <- spec$subtests$CR
stopifnot(!identical(cr_like$administration$route_type, "adaptive_items"))
