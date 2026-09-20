#!/usr/bin/env Rscript

# Generatore delle sequenze di SM (Sequenze e Manipolazione).
#
#   Rscript R/build/build_sm_items.R
#
# ATTENZIONE alla fonte di verita: il file `items/source/SM.csv` e la fonte, ed
# e modificabile a mano come tutti gli altri item bank. Questo script produce
# una prima versione riproducibile e documenta quali vincoli rispettano le
# sequenze; **non** viene eseguito dal rebuild e non sovrascrive il CSV se non
# lo si lancia esplicitamente.
#
# I vincoli sono verificati in modo indipendente da `tests/test_sm_scoring.R`,
# che controlla il CSV e non l'output di questo script: sequenze modificate a
# mano restano quindi sotto controllo.

BII_SM_SEED <- 20260912L
BII_SM_DIGITS <- 1:9  # niente 0: evita ambiguita fonetica con "oh"/"zero"
BII_SM_RUNNING_SPAN_BUFFER <- 3L  # quanti digit in piu si presentano rispetto al livello, in running_span

bii_sm_root <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) == 1L) {
    script <- normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE))
  }
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

# --- vincoli sulle sequenze ---------------------------------------------------
# Sono le proprieta che impediscono a una sequenza di risolversi con una
# scorciatoia (contare, notare che e gia ordinata, individuare un pattern)
# invece di richiedere il mantenimento/manipolazione effettivo.

# Nessuna run di 3+ interi consecutivi in posizioni adiacenti (ascendente o
# discendente): un "4 5 6" si ricorda come blocco, non come tre cifre separate.
sm_no_consecutive_run <- function(seq) {
  if (length(seq) < 3L) return(TRUE)
  for (i in seq_len(length(seq) - 2L)) {
    d1 <- seq[i + 1L] - seq[i]
    d2 <- seq[i + 2L] - seq[i + 1L]
    if (abs(d1) == 1L && d1 == d2) return(FALSE)
  }
  TRUE
}

sm_not_monotonic <- function(seq) {
  if (length(seq) < 3L) return(TRUE)
  !(all(diff(seq) > 0) || all(diff(seq) < 0))
}

sm_draw_distinct <- function(digits, length_wanted, extra_checks, max_attempts = 20000L) {
  for (attempt in seq_len(max_attempts)) {
    candidate <- sample(digits, length_wanted, replace = FALSE)
    if (sm_no_consecutive_run(candidate) && all(vapply(extra_checks, function(f) f(candidate), logical(1)))) {
      return(candidate)
    }
  }
  stop("Impossibile generare una sequenza valida di lunghezza ", length_wanted, ".", call. = FALSE)
}

# Come sopra ma con ripetizione ammessa (serve quando la lista presentata supera
# le nove cifre disponibili, cioe in running_span ai livelli piu alti). Vietato
# solo il caso che renderebbe ambigua la lettura: due cifre identiche di seguito.
sm_draw_with_repeats <- function(digits, length_wanted, extra_checks, max_attempts = 20000L) {
  for (attempt in seq_len(max_attempts)) {
    candidate <- sample(digits, length_wanted, replace = TRUE)
    if (all(candidate[-1] != candidate[-length_wanted]) &&
        sm_no_consecutive_run(candidate) &&
        all(vapply(extra_checks, function(f) f(candidate), logical(1)))) {
      return(candidate)
    }
  }
  stop("Impossibile generare una sequenza valida di lunghezza ", length_wanted, ".", call. = FALSE)
}

# backward_repetition: si presenta la sequenza, si richiama al contrario.
sm_backward_item <- function(level) {
  presented <- sm_draw_distinct(BII_SM_DIGITS, level, list(sm_not_monotonic))
  list(sequence = presented, target = rev(presented))
}

# rule_based_reordering: si presenta la sequenza, si richiama in ordine
# crescente. La sequenza presentata non deve essere gia ordinata (altrimenti
# non c'e manipolazione da fare) e, dal livello 3 in su, non deve essere
# l'esatto opposto dell'ordinamento richiesto (altrimenti coincide con
# backward_repetition). A livello 2 il secondo vincolo e irrealizzabile: con
# due elementi distinti l'unico ordine diverso da quello crescente e proprio
# il suo opposto, quindi a quel livello resta solo il primo vincolo.
sm_reordering_item <- function(level) {
  extra <- list(function(x) !all(x == sort(x)))
  if (level >= 3L) {
    extra <- c(extra, list(function(x) !all(x == sort(x, decreasing = TRUE))))
  }
  presented <- sm_draw_distinct(BII_SM_DIGITS, level, extra)
  list(sequence = presented, target = sort(presented))
}

# running_span: si presenta una lista piu lunga del livello; si richiamano solo
# gli ultimi "level" digit nell'ordine in cui sono stati detti. Il buffer
# iniziale costringe ad aggiornare la memoria e a scartare le cifre piu vecchie.
# Ai livelli alti la lista presentata supera le nove cifre disponibili, quindi
# qui si ammette la ripetizione (mai adiacente) invece che l'unicita totale.
sm_running_span_item <- function(level, buffer = BII_SM_RUNNING_SPAN_BUFFER) {
  total <- level + buffer
  target_not_monotonic <- function(x) sm_not_monotonic(utils::tail(x, level))
  presented <- if (total <= length(BII_SM_DIGITS)) {
    sm_draw_distinct(BII_SM_DIGITS, total, list(target_not_monotonic))
  } else {
    sm_draw_with_repeats(BII_SM_DIGITS, total, list(target_not_monotonic))
  }
  list(sequence = presented, target = utils::tail(presented, level))
}

sm_family_fn <- list(
  backward_repetition = sm_backward_item,
  rule_based_reordering = sm_reordering_item,
  running_span = sm_running_span_item
)

sm_prompt <- function(microblock, level, sequence) {
  txt <- paste(sequence, collapse = " ")
  switch(
    microblock,
    backward_repetition = paste0("Di' i numeri al contrario: ", txt),
    rule_based_reordering = paste0("Di' questi numeri dal piu piccolo al piu grande: ", txt),
    running_span = paste0("Dimmi solo gli ultimi ", level, " numeri che ti ho detto: ", txt)
  )
}

# Ancora per famiglia: ogni microblocco ha una sua sezione di istruzioni nella
# rubrica, e i suoi item puntano li, non a un'unica "chiave rapida" condivisa.
sm_rubric_ref <- function(microblock, item_type) {
  anchor <- switch(
    microblock,
    backward_repetition = "1-ripetizione-a-ritroso",
    rule_based_reordering = "2-riordino-per-regola",
    running_span = "3-span-aggiornato"
  )
  paste0("items/rubrics/SM.md#", anchor)
}

sm_rubric <- function(target) {
  txt <- paste(target, collapse = " ")
  paste0(
    "1 = dice esattamente \"", txt, "\" nello stesso ordine; ",
    "0 = qualunque omissione, aggiunta, sostituzione o errore d'ordine."
  )
}

build_sm_items <- function(root, seed = BII_SM_SEED) {
  loader <- file.path(root, "R", "items", "load_items.R")
  if (!exists("bii_spec", mode = "function")) source(loader)
  spec <- bii_spec(root)
  st <- spec$subtests$SM

  microblocks <- unlist(st$microblocks, use.names = FALSE)
  trials <- as.integer(st$administration$trials_per_level)
  n_scored <- as.integer(st$n_scored_items)
  n_per_block <- n_scored / length(microblocks)
  n_levels <- n_per_block / trials
  if (n_levels != round(n_levels)) {
    stop("n_scored_items non si divide in livelli interi per microblocco.", call. = FALSE)
  }
  min_level <- min(vapply(
    st$administration$start_points,
    function(rule) as.integer(rule$sequence_length), integer(1)
  ))
  levels_used <- seq.int(min_level, min_level + n_levels - 1L)
  # Scala progettuale comune a tutti i microblocchi: e un'assunzione dichiarata,
  # non una stima. Vedi items/design/SM.md.
  step <- 6 / (n_levels - 1)
  target_for_level <- setNames(-3 + (seq_along(levels_used) - 1L) * step, levels_used)

  set.seed(seed)
  rows <- list()
  order_counter <- 0L
  for (microblock in microblocks) {
    draw <- sm_family_fn[[microblock]]
    for (level in levels_used) {
      for (trial in seq_len(trials)) {
        order_counter <- order_counter + 1L
        item <- draw(level)
        sequence <- paste(item$sequence, collapse = " ")
        target <- paste(item$target, collapse = " ")
        rows[[length(rows) + 1L]] <- data.frame(
          item_id = sprintf("SM-SC-%02d", order_counter),
          subtest = "SM",
          item_type = "scored",
          order = order_counter,
          family = microblock,
          microblock = microblock,
          difficulty_rank = level - min_level + 1L,
          difficulty_target = unname(target_for_level[as.character(level)]),
          level = level,
          trial = trial,
          sequence = sequence,
          target = target,
          prompt = sm_prompt(microblock, level, item$sequence),
          scoring_key = target,
          max_points = 1L,
          scoring_rubric = sm_rubric(item$target),
          rubric_ref = sm_rubric_ref(microblock, "scored"),
          source_status = "mock",
          review_status = "draft",
          stringsAsFactors = FALSE
        )
      }
    }
  }

  practice <- lapply(seq_along(microblocks), function(i) {
    microblock <- microblocks[i]
    draw <- sm_family_fn[[microblock]]
    item <- draw(min_level)
    sequence <- paste(item$sequence, collapse = " ")
    target <- paste(item$target, collapse = " ")
    data.frame(
      item_id = sprintf("SM-PR-%02d", i),
      subtest = "SM", item_type = "practice", order = i,
      family = microblock, microblock = microblock,
      difficulty_rank = 1L, difficulty_target = -3.5,
      level = min_level, trial = 1L,
      sequence = sequence, target = target,
      prompt = sm_prompt(microblock, min_level, item$sequence),
      scoring_key = target,
      max_points = 1L,
      scoring_rubric = "Item di prova: si mostra la risposta corretta se sbaglia. Non entra nel punteggio.",
      rubric_ref = sm_rubric_ref(microblock, "practice"),
      source_status = "mock", review_status = "draft",
      stringsAsFactors = FALSE
    )
  })

  out <- do.call(rbind, c(practice, rows))
  path <- file.path(root, "items", "source", "SM.csv")
  utils::write.csv(out, path, row.names = FALSE, na = "")
  path
}

if (sys.nframe() == 0L) {
  root <- bii_sm_root()
  source(file.path(root, "R", "items", "load_items.R"))
  message("[SM] ", build_sm_items(root))
  message("[OK] Sequenze SM generate. items/source/SM.csv resta la fonte modificabile.")
}
