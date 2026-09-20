source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)

pg <- load_item_bank("PG", root)
items <- pg$items
stopifnot(nrow(items) == 16L, nrow(pg$practice) == 2L)

trials_per_level <- as.integer(pg$spec$administration$trials_per_level)
levels_present <- sort(unique(items$level))
stopifnot(
  identical(pg$spec$administration$route_type, "adaptive_levels"),
  trials_per_level == 2L,
  identical(levels_present, 2:9),
  # ogni livello ha esattamente il numero di prove dichiarato dalla spec
  all(table(items$level) == trials_per_level),
  # le due prove dello stesso livello hanno la stessa difficolta progettuale
  all(tapply(items$difficulty_target, items$level, function(x) length(unique(x))) == 1L)
)

# --- vincoli sulle sequenze, verificati sul CSV -------------------------------
# Il controllo e sul file, non sull'output del generatore: una sequenza
# sostituita a mano resta sotto controllo.

grid <- as.integer(unlist(pg$spec$grid_size, use.names = FALSE))
valid_cells <- paste0(rep(LETTERS[seq_len(grid[2])], each = grid[1]), rep(seq_len(grid[1]), grid[2]))

for (i in seq_len(nrow(items))) {
  cells <- strsplit(trimws(items$sequence[i]), " +")[[1]]
  id <- items$item_id[i]
  if (!all(cells %in% valid_cells)) stop(id, ": cella fuori dalla griglia dichiarata.")
  if (length(cells) != items$level[i]) stop(id, ": lunghezza della sequenza diversa dal livello.")
  if (any(cells[-1] == cells[-length(cells)])) stop(id, ": cella ripetuta di seguito.")
  if (max(table(cells)) > 2L) stop(id, ": una cella compare piu di due volte.")

  xy <- vapply(cells, function(cell) {
    c(match(substr(cell, 1, 1), LETTERS), as.integer(substr(cell, 2, 2)))
  }, integer(2))

  # Nessuna terna consecutiva allineata: escluderebbe un segmento di retta,
  # ricordabile come forma invece che come serie di posizioni.
  if (length(cells) >= 3L) {
    for (k in seq_len(ncol(xy) - 2L)) {
      d1 <- xy[, k + 1L] - xy[, k]
      d2 <- xy[, k + 2L] - xy[, k + 1L]
      if (d1[1] * d2[2] - d1[2] * d2[1] == 0L) stop(id, ": tre posizioni consecutive allineate.")
    }
  }
  # Non piu della meta dei passaggi fra celle contigue: un percorso continuo si
  # ricorda come tracciato.
  if (length(cells) >= 2L) {
    steps <- vapply(seq_len(ncol(xy) - 1L), function(k) sum(abs(xy[, k + 1L] - xy[, k])) == 1L, logical(1))
    if (sum(steps) > floor(length(steps) / 2)) stop(id, ": troppi passaggi fra celle contigue.")
  }
  # Il prompt e la chiave devono citare la sequenza: divergendo, l'esaminatore
  # mostrerebbe una sequenza e ne correggerebbe un'altra.
  if (!grepl(items$sequence[i], items$prompt[i], fixed = TRUE) ||
      !grepl(items$sequence[i], items$scoring_key[i], fixed = TRUE)) {
    stop(id, ": prompt o chiave non citano la sequenza dell'item bank.")
  }
}

# --- routing a livelli --------------------------------------------------------

# Indici delle prove di un livello, per costruire i casi a mano.
at <- function(level) which(items$level == level)

# Sedicenne: parte dal livello 4. Tutto corretto fino al livello 6, poi
# entrambe le prove del 7 sbagliate: si interrompe al 7.
scores <- rep(0, 16)
scores[items$level <= 6] <- 1
teen <- route_subtest("PG", scores, age_months = 200, root = root)
stopifnot(
  identical(attr(teen, "start_level"), 4L),
  !isTRUE(attr(teen, "inversion_applied")),
  # livelli 2 e 3 non somministrati, credito pieno
  all(teen$administration_status[items$level < 4] == "below_basal"),
  all(teen$administration_status[items$level >= 4 & items$level <= 7] == "administered"),
  all(teen$administration_status[items$level > 7] == "above_ceiling"),
  identical(unname(attr(teen, "ceiling_level")), 7L)
)
# Punteggio a mano: 4 prove inferite (livelli 2-3) + le corrette fra 4 e 6.
stopifnot(sum(teen$assigned_score) == 4 * 1 + sum(scores[items$level >= 4 & items$level <= 6]))

# Una prova corretta e una sbagliata al livello di partenza: non si scende, si
# sale, e i livelli piu bassi ricevono comunque credito pieno.
mixed <- rep(0, 16)
mixed[at(4)[1]] <- 1
mixed[at(5)] <- 1
half <- route_subtest("PG", mixed, age_months = 200, root = root)
stopifnot(
  !isTRUE(attr(half, "inversion_applied")),
  all(half$administration_status[items$level < 4] == "below_basal"),
  identical(unname(attr(half, "ceiling_level")), 6L)
)

# Entrambe sbagliate al livello di partenza: si scende. Basale al livello 3.
down <- rep(0, 16)
down[at(3)] <- 1
down[at(2)] <- 1
inverted <- route_subtest("PG", down, age_months = 200, root = root)
stopifnot(
  isTRUE(attr(inverted, "inversion_applied")),
  identical(unname(attr(inverted, "basal_level")), 3L),
  # il livello 3 e stato somministrato e ha fermato la discesa
  all(inverted$administration_status[items$level == 3] == "administered"),
  # il livello 2 sta sotto il basale e riceve credito pieno senza essere usato
  all(inverted$administration_status[items$level == 2] == "below_basal"),
  # il ceiling e il livello di partenza stesso: entrambe le prove sbagliate
  identical(unname(attr(inverted, "ceiling_level")), 4L),
  all(inverted$administration_status[items$level > 4] == "above_ceiling")
)
# A mano: 2 prove inferite al livello 2 + 2 corrette al livello 3 + 0 altrove.
stopifnot(sum(inverted$assigned_score) == 2 + 2)

# Si scende fino al livello piu basso senza trovare il basale: non si inferisce
# nulla sotto e nessun livello riceve credito non guadagnato.
never <- rep(0, 16)
none <- route_subtest("PG", never, age_months = 200, root = root)
stopifnot(
  isTRUE(attr(none, "inversion_applied")),
  is.na(unname(attr(none, "basal_level"))),
  all(none$administration_status[items$level <= 4] == "administered"),
  sum(none$assigned_score) == 0
)

# Un bambino parte dal livello piu basso: non c'e niente sotto da inferire.
child <- rep(0, 16)
child[items$level <= 3] <- 1
young <- route_subtest("PG", child, age_months = 84, root = root)
stopifnot(
  identical(attr(young, "start_level"), 2L),
  !any(young$administration_status == "below_basal"),
  identical(unname(attr(young, "ceiling_level")), 4L),
  sum(young$assigned_score) == 4
)

# Chi arriva in cima non tocca nessun ceiling e ottiene il massimo dalla spec.
top <- route_subtest("PG", rep(1, 16), age_months = 200, root = root)
stopifnot(
  is.na(unname(attr(top, "ceiling_level"))),
  sum(top$assigned_score) == pg$spec$scoring$raw_max
)

# --- scoring del record -------------------------------------------------------

record <- data.frame(
  item_id = teen$item_id,
  administration_status = teen$administration_status,
  item_score = teen$observed_score,
  stringsAsFactors = FALSE
)
scored <- score_subtest_record("PG", record, root)
stopifnot(scored$valid, scored$raw_score == sum(teen$assigned_score), scored$raw_max == 16)

record$administration_status[1] <- "external_missing"
record$item_score[1] <- NA
stopifnot(!score_subtest_record("PG", record, root)$valid)

form <- utils::read.csv(
  file.path(root, "materials", "record_forms", "PG_record_form.csv"),
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(identical(form[form$item_type == "scored", "item_id"], items$item_id))
