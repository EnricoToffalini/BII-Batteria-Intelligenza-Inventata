source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)

sm <- load_item_bank("SM", root)
items <- sm$items
stopifnot(nrow(items) == 36L, nrow(sm$practice) == 3L)

trials_per_level <- as.integer(sm$spec$administration$trials_per_level)
microblocks <- unlist(sm$spec$microblocks, use.names = FALSE)
stopifnot(
  identical(sm$spec$administration$route_type, "adaptive_levels_by_microblock"),
  trials_per_level == 2L,
  identical(sort(unique(items$microblock)), sort(microblocks)),
  identical(sort(unique(items$level)), 2:7),
  all(table(items$microblock, items$level) == trials_per_level),
  nrow(sm$practice) == length(microblocks),
  # ogni microblocco ha esattamente un item di prova
  identical(sort(sm$practice$microblock), sort(microblocks))
)

# --- correttezza logica delle sequenze, verificata sul CSV --------------------
# Non ci si limita a controllare la forma: si ricalcola il target atteso da
# ciascuna regola dichiarata e si confronta con quello nell'item bank.

for (i in seq_len(nrow(items))) {
  seq_val <- as.integer(strsplit(trimws(items$sequence[i]), " +")[[1]])
  target_val <- as.integer(strsplit(trimws(items$target[i]), " +")[[1]])
  id <- items$item_id[i]
  expected <- switch(
    items$microblock[i],
    backward_repetition = rev(seq_val),
    rule_based_reordering = sort(seq_val),
    running_span = utils::tail(seq_val, items$level[i])
  )
  if (!identical(target_val, expected)) stop(id, ": target non coerente con la regola del microblocco.")
  if (any(seq_val < 1L | seq_val > 9L)) stop(id, ": cifra fuori dal range 1-9.")
  if (any(seq_val[-1] == seq_val[-length(seq_val)])) stop(id, ": cifra ripetuta di seguito.")
  if (items$microblock[i] != "running_span" && length(seq_val) != items$level[i]) {
    stop(id, ": lunghezza della sequenza diversa dal livello dichiarato.")
  }
  if (items$microblock[i] == "running_span" && length(target_val) != items$level[i]) {
    stop(id, ": running_span deve richiamare esattamente 'level' cifre.")
  }
  if (!grepl(items$sequence[i], items$prompt[i], fixed = TRUE)) {
    stop(id, ": il prompt non cita la sequenza dell'item bank.")
  }
}

# rule_based_reordering: dal livello 3 in su la sequenza presentata non deve
# essere l'esatto opposto del target (altrimenti coincide con backward_repetition).
reordering <- items[items$microblock == "rule_based_reordering" & items$level >= 3, ]
for (i in seq_len(nrow(reordering))) {
  seq_val <- as.integer(strsplit(trimws(reordering$sequence[i]), " +")[[1]])
  if (identical(seq_val, rev(sort(seq_val)))) {
    stop(reordering$item_id[i], ": la sequenza presentata e l'esatto opposto del target richiesto.")
  }
}

# --- routing: microblocchi indipendenti nella stessa somministrazione --------

at <- function(microblock, level) which(items$microblock == microblock & items$level == level)

# Sedicenne (start livello 4): va bene nel primo microblocco fino al 6 e si
# interrompe al 7; va male da subito nel secondo (basale trovato scendendo al
# livello 2); fa tutto bene nel terzo (arriva al massimo, nessun ceiling).
scores <- rep(0, 36)
scores[items$microblock == "backward_repetition" & items$level <= 6] <- 1
scores[items$microblock == "rule_based_reordering" & items$level == 2] <- 1
scores[items$microblock == "running_span"] <- 1
teen <- route_subtest("SM", scores, age_months = 200, root = root)

stopifnot(identical(attr(teen, "start_level"), 4L))

by_group <- attr(teen, "inversion_by_group")
basal_by_group <- attr(teen, "basal_level")
ceiling_by_group <- attr(teen, "ceiling_level")

stopifnot(
  # primo microblocco: nessuna inversione, ceiling al livello 7
  !isTRUE(by_group[["backward_repetition"]]),
  identical(unname(ceiling_by_group[["backward_repetition"]]), 7L),
  all(teen$administration_status[at("backward_repetition", 2)] == "below_basal"),
  all(teen$administration_status[at("backward_repetition", 3)] == "below_basal"),
  all(teen$administration_status[at("backward_repetition", 7)] == "administered"),

  # secondo microblocco: entrambe le prove al livello di partenza falliscono,
  # quindi scatta sia l'inversione (si scende in cerca del basale) sia il
  # ceiling proprio al livello di partenza (la finestra iniziale e comunque
  # osservata) -- stessa convenzione gia verificata per PG.
  isTRUE(by_group[["rule_based_reordering"]]),
  identical(unname(basal_by_group[["rule_based_reordering"]]), 2L),
  identical(unname(ceiling_by_group[["rule_based_reordering"]]), 4L),
  all(teen$administration_status[at("rule_based_reordering", 3)] == "administered"),
  all(teen$administration_status[at("rule_based_reordering", 4)] == "administered"),
  all(teen$administration_status[at("rule_based_reordering", 5)] == "above_ceiling"),
  all(teen$administration_status[at("rule_based_reordering", 7)] == "above_ceiling"),

  # terzo microblocco: tutto corretto, nessun ceiling, credito pieno sotto il 4
  !isTRUE(by_group[["running_span"]]),
  is.na(unname(ceiling_by_group[["running_span"]])),
  all(teen$administration_status[at("running_span", 2)] == "below_basal"),
  all(teen$administration_status[at("running_span", 7)] == "administered")
)

# Punteggio calcolato a mano, microblocco per microblocco. I livelli 2 e 3
# sono below_basal (4 item, credito pieno = 1 ciascuno); 4-7 sono administered.
manual_backward <- 4 * 1 + sum(scores[items$microblock == "backward_repetition" & items$level >= 4 & items$level <= 7])
# reordering: solo il livello 2 e administered-e-corretto (credito diretto, non
# below_basal); i livelli 3-4 sono administered ma a punteggio 0; 5-7 sopra ceiling.
manual_reordering <- sum(scores[at("rule_based_reordering", 2)])
manual_running <- sum(scores[items$microblock == "running_span"])
stopifnot(sum(teen$assigned_score) == manual_backward + manual_reordering + manual_running)

# Il fallimento in un microblocco non deve intaccare gli altri: il conteggio di
# item somministrati per blocco deve restare indipendente.
n_administered_by_block <- tapply(
  teen$administration_status == "administered", items$microblock, sum
)
stopifnot(all(n_administered_by_block > 0))

# --- caso limite: si scende fino in fondo senza trovare basale in nessun microblocco --

none <- route_subtest("SM", rep(0, 36), age_months = 200, root = root)
stopifnot(
  all(is.na(attr(none, "basal_level"))),
  all(none$administration_status[items$level <= 4] == "administered"),
  sum(none$assigned_score) == 0
)

# --- massimo teorico ------------------------------------------------------------

top <- route_subtest("SM", rep(1, 36), age_months = 200, root = root)
stopifnot(sum(top$assigned_score) == sm$spec$scoring$raw_max)

# --- scoring del record ---------------------------------------------------------

record <- data.frame(
  item_id = teen$item_id,
  administration_status = teen$administration_status,
  item_score = teen$observed_score,
  stringsAsFactors = FALSE
)
scored <- score_subtest_record("SM", record, root)
stopifnot(scored$valid, scored$raw_score == sum(teen$assigned_score), scored$raw_max == 36)

record$administration_status[1] <- "invalidated"
record$item_score[1] <- NA
stopifnot(!score_subtest_record("SM", record, root)$valid)

# --- modulo di registrazione -----------------------------------------------------

form <- utils::read.csv(
  file.path(root, "materials", "record_forms", "SM_record_form.csv"),
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(
  identical(form[form$item_type == "scored", "item_id"], items$item_id),
  identical(form[form$item_type == "practice", "item_id"], sm$practice$item_id)
)
