#!/usr/bin/env Rscript

# Generatore delle sequenze di PG (Posizioni su Griglia).
#
#   Rscript R/build/build_pg_items.R
#
# ATTENZIONE alla fonte di verita: il file `items/source/PG.csv` e la fonte,
# ed e modificabile a mano come tutti gli altri item bank. Questo script serve
# a produrre una prima versione riproducibile e a documentare quali vincoli
# rispettano le sequenze; **non** viene eseguito dal rebuild e non sovrascrive
# il CSV se non lo si lancia esplicitamente.
#
# I vincoli sono verificati in modo indipendente da `tests/test_pg_scoring.R`,
# che controlla il CSV e non l'output di questo script: sequenze modificate a
# mano restano quindi sotto controllo.

BII_PG_SEED <- 20260912L

bii_pg_root <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) == 1L) {
    script <- normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE))
  }
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

# Celle di una griglia rows x cols con notazione colonna-lettera + riga-numero.
pg_cells <- function(rows, cols) {
  grid <- expand.grid(row = seq_len(rows), col = seq_len(cols))
  paste0(LETTERS[grid$col], grid$row)
}

pg_coords <- function(cell) {
  c(col = match(substr(cell, 1, 1), LETTERS), row = as.integer(substr(cell, 2, 2)))
}

# --- vincoli sulle sequenze ---------------------------------------------------
# Sono le proprieta che rendono la sequenza una prova di memoria spaziale e non
# di riconoscimento di una figura: una sequenza che disegna una linea o un
# quadrato si ricorda come forma, non come serie di posizioni.

pg_no_immediate_repeat <- function(seq) all(seq[-1] != seq[-length(seq)])

pg_no_cell_more_than_twice <- function(seq) max(table(seq)) <= 2L

# Nessuna terna consecutiva allineata: esclude segmenti di retta riconoscibili.
pg_no_collinear_triple <- function(seq) {
  if (length(seq) < 3L) return(TRUE)
  xy <- vapply(seq, pg_coords, integer(2))
  for (i in seq_len(ncol(xy) - 2L)) {
    d1 <- xy[, i + 1L] - xy[, i]
    d2 <- xy[, i + 2L] - xy[, i + 1L]
    if (d1[1] * d2[2] - d1[2] * d2[1] == 0L) return(FALSE)
  }
  TRUE
}

# Non piu della meta dei passaggi fra celle contigue: troppi passaggi contigui
# trasformano la sequenza in un percorso continuo, piu facile da ricordare.
pg_limited_adjacency <- function(seq) {
  if (length(seq) < 2L) return(TRUE)
  xy <- vapply(seq, pg_coords, integer(2))
  steps <- vapply(seq_len(ncol(xy) - 1L), function(i) {
    d <- abs(xy[, i + 1L] - xy[, i])
    sum(d) == 1L
  }, logical(1))
  sum(steps) <= floor(length(steps) / 2)
}

pg_sequence_is_valid <- function(seq) {
  pg_no_immediate_repeat(seq) &&
    pg_no_cell_more_than_twice(seq) &&
    pg_no_collinear_triple(seq) &&
    pg_limited_adjacency(seq)
}

pg_draw_sequence <- function(cells, length_wanted, max_attempts = 20000L) {
  for (attempt in seq_len(max_attempts)) {
    candidate <- sample(cells, length_wanted, replace = TRUE)
    if (pg_sequence_is_valid(candidate)) return(candidate)
  }
  stop("Impossibile generare una sequenza valida di lunghezza ", length_wanted, ".", call. = FALSE)
}

build_pg_items <- function(root, seed = BII_PG_SEED) {
  loader <- file.path(root, "R", "items", "load_items.R")
  if (!exists("bii_spec", mode = "function")) source(loader)
  spec <- bii_spec(root)
  st <- spec$subtests$PG

  grid <- as.integer(unlist(st$grid_size, use.names = FALSE))
  cells <- pg_cells(grid[1], grid[2])
  trials <- as.integer(st$administration$trials_per_level)
  n_scored <- as.integer(st$n_scored_items)
  n_levels <- n_scored / trials
  if (n_levels != round(n_levels)) {
    stop("n_scored_items non e un multiplo di trials_per_level.", call. = FALSE)
  }
  # I livelli partono dalla lunghezza minima prevista dai punti di partenza.
  min_level <- min(vapply(
    st$administration$start_points,
    function(rule) as.integer(rule$sequence_length), integer(1)
  ))
  levels_used <- seq.int(min_level, min_level + n_levels - 1L)

  set.seed(seed)
  rows <- list()
  order_counter <- 0L
  for (level in levels_used) {
    for (trial in seq_len(trials)) {
      order_counter <- order_counter + 1L
      seq_cells <- pg_draw_sequence(cells, level)
      sequence <- paste(seq_cells, collapse = " ")
      rows[[length(rows) + 1L]] <- data.frame(
        item_id = sprintf("PG-SC-%02d", order_counter),
        subtest = "PG",
        item_type = "scored",
        order = order_counter,
        family = sprintf("span_%d", level),
        difficulty_rank = level - min_level + 1L,
        difficulty_target = -2.5 + (level - min_level) * 0.7,
        level = level,
        trial = trial,
        sequence = sequence,
        prompt = paste0("Toccare in ordine: ", sequence),
        scoring_key = paste0("Ripete esattamente ", sequence, " nello stesso ordine."),
        max_points = 1L,
        scoring_rubric = "1 = riproduce tutte le posizioni nell'ordine esatto; 0 = qualunque omissione, aggiunta, sostituzione o inversione.",
        rubric_ref = "items/rubrics/PG.md#chiave-rapida",
        source_status = "mock",
        review_status = "draft",
        stringsAsFactors = FALSE
      )
    }
  }

  # Due item di prova alla lunghezza minima, fuori dal conteggio scored.
  practice <- lapply(seq_len(as.integer(st$n_practice_items)), function(i) {
    seq_cells <- pg_draw_sequence(cells, min_level)
    sequence <- paste(seq_cells, collapse = " ")
    data.frame(
      item_id = sprintf("PG-PR-%02d", i),
      subtest = "PG", item_type = "practice", order = i,
      family = sprintf("span_%d", min_level),
      difficulty_rank = 1L, difficulty_target = -3.0,
      level = min_level, trial = i, sequence = sequence,
      prompt = paste0("Toccare in ordine: ", sequence),
      scoring_key = paste0("Ripete esattamente ", sequence, " nello stesso ordine."),
      max_points = 1L,
      scoring_rubric = "Item di prova: si mostra la risposta corretta se sbaglia. Non entra nel punteggio.",
      rubric_ref = "items/rubrics/PG.md#item-di-prova",
      source_status = "mock", review_status = "draft",
      stringsAsFactors = FALSE
    )
  })

  out <- do.call(rbind, c(practice, rows))
  path <- file.path(root, "items", "source", "PG.csv")
  utils::write.csv(out, path, row.names = FALSE, na = "")
  path
}

if (sys.nframe() == 0L) {
  root <- bii_pg_root()
  source(file.path(root, "R", "items", "load_items.R"))
  message("[PG] ", build_pg_items(root))
  message("[OK] Sequenze PG generate. items/source/PG.csv resta la fonte modificabile.")
}
