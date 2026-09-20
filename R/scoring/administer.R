# Motore generico di somministrazione adattiva e scoring response-level.
#
# Le regole non sono scritte qui: vengono lette da spec/subtests/<ID>.yml.
# Aggiungere un subtest adattivo per item significa quindi scrivere la sua
# spec e il suo item bank, non un nuovo file di scoring.
#
# Stati di somministrazione (spec/battery.yml -> administration.response_statuses):
#   administered      risposta osservata
#   omitted           item presentato senza risposta -> 0 punti
#   below_basal       non somministrato sotto basale -> credito pieno inferito
#   above_ceiling     non somministrato sopra ceiling -> 0 punti inferiti
#   external_missing  non somministrato per ragione esterna -> mai un errore
#   invalidated       item invalidato -> mai un errore

if (!exists("load_item_bank", mode = "function")) {
  .bii_engine_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(.bii_engine_root, "R", "items", "load_items.R"))) break
    .bii_engine_parent <- dirname(.bii_engine_root)
    if (identical(.bii_engine_parent, .bii_engine_root)) stop("Repository BII non trovato.", call. = FALSE)
    .bii_engine_root <- .bii_engine_parent
  }
  source(file.path(.bii_engine_root, "R", "items", "load_items.R"), local = TRUE)
}

BII_RESPONSE_STATUSES <- c(
  "administered", "omitted", "below_basal",
  "above_ceiling", "external_missing", "invalidated"
)

bii_item_scores <- function(st_spec) {
  as.numeric(unlist(st_spec$scoring$item_scores, use.names = FALSE))
}

bii_full_credit <- function(st_spec) {
  value <- st_spec$scoring$full_credit_for_below_basal
  if (is.null(value)) max(bii_item_scores(st_spec)) else as.numeric(value)
}

# Punto di partenza per eta; il subtest dichiara le fasce nella sua spec.
subtest_start_item <- function(age_months, st_spec) {
  age_months <- suppressWarnings(as.integer(age_months))
  if (length(age_months) != 1L || is.na(age_months)) {
    stop("age_months deve contenere una sola eta valida in mesi.", call. = FALSE)
  }
  for (rule in st_spec$administration$start_points) {
    limits <- as.integer(unlist(rule$age_months, use.names = FALSE))
    if (age_months >= limits[1] && age_months <= limits[2]) return(as.integer(rule$item))
  }
  stop("Eta fuori dal range previsto dalla BII: ", age_months, " mesi.", call. = FALSE)
}

# Verifica un criterio di finestra espresso come `total_score` oppure `correct`.
bii_window_met <- function(scores, criterion, max_score) {
  if (!is.null(criterion$total_score)) {
    return(sum(scores) >= as.numeric(criterion$total_score))
  }
  if (!is.null(criterion$correct)) {
    return(sum(scores >= max_score) >= as.integer(criterion$correct))
  }
  stop("Criterio di basale non riconosciuto: servono total_score o correct.", call. = FALSE)
}

# Verifica il trigger di inversione sulla finestra iniziale.
bii_inversion_triggered <- function(scores, trigger, max_score) {
  if (!is.null(trigger$total_score_lt)) {
    return(sum(scores) < as.numeric(trigger$total_score_lt))
  }
  if (!is.null(trigger$correct_lt)) {
    return(sum(scores >= max_score) < as.integer(trigger$correct_lt))
  }
  stop("Trigger di inversione non riconosciuto: servono total_score_lt o correct_lt.", call. = FALSE)
}

# Applica il routing adattivo a un vettore di punteggi "completi", cioe ai
# punteggi che si sarebbero osservati somministrando ogni item. Serve per la
# simulazione e per i test: nella pratica il vettore completo non esiste, per
# questo lo scoring di una somministrazione vera passa da score_subtest_record().
route_subtest <- function(subtest_id, complete_scores, age_months, root = NULL, context = NULL) {
  if (is.null(context)) context <- load_item_bank(subtest_id, root)
  route_type <- context$spec$administration$route_type
  handler <- BII_ROUTE_HANDLERS[[route_type]]
  if (is.null(handler)) {
    stop(
      subtest_id, ": route_type '", route_type,
      "' non e ancora gestito dal motore. Implementati: ",
      paste(names(BII_ROUTE_HANDLERS), collapse = ", "), ".",
      call. = FALSE
    )
  }
  handler(subtest_id, complete_scores, age_months, context)
}

# Handler per route_type: adaptive_items.
# Progressione per item con finestra iniziale, inversione, basale e ceiling.
bii_route_adaptive_items <- function(subtest_id, complete_scores, age_months, context) {
  st <- context$spec
  items <- context$items
  n_items <- nrow(items)

  scores <- suppressWarnings(as.numeric(complete_scores))
  allowed <- bii_item_scores(st)
  if (length(scores) != n_items || anyNA(scores) || any(!scores %in% allowed)) {
    stop(
      subtest_id, ": complete_scores deve contenere uno dei punteggi ",
      paste(allowed, collapse = "/"), " per ciascuno dei ", n_items, " item scored.",
      call. = FALSE
    )
  }
  max_score <- max(allowed)

  start <- subtest_start_item(age_months, st)
  if (start > n_items) {
    stop(
      subtest_id, ": il punto di partenza per questa eta e l'item ", start,
      " ma l'item bank ne contiene solo ", n_items,
      ". Completare l'item bank prima di somministrare o simulare il subtest.",
      call. = FALSE
    )
  }
  initial_n <- as.integer(st$administration$inversion$initial_window_items)
  initial <- start:min(start + initial_n - 1L, n_items)
  status <- rep("not_administered", n_items)
  status[initial] <- "administered"

  inversion <- bii_inversion_triggered(
    scores[initial], st$administration$inversion$trigger, max_score
  )
  basal_start <- NA_integer_
  presented_below_basal <- integer(0)

  basal_n <- as.integer(st$administration$basal$window_items)
  direction <- st$administration$inversion$direction
  block <- if (identical(direction, "backward_in_blocks")) {
    as.integer(st$administration$inversion$block_size)
  } else {
    1L
  }
  if (is.na(block) || block < 1L) {
    stop(subtest_id, ": block_size di inversione non valido.", call. = FALSE)
  }

  if (inversion && start > 1L) {
    cursor <- start - 1L
    while (cursor >= 1L && is.na(basal_start)) {
      lowest <- max(1L, cursor - block + 1L)
      status[lowest:cursor] <- "administered"
      # Si cerca la finestra di basale piu alta fra quelle diventate complete.
      for (i in seq.int(cursor, lowest)) {
        window <- i:(i + basal_n - 1L)
        if (window[basal_n] > n_items) next
        if (!all(status[window] == "administered")) next
        if (bii_window_met(scores[window], st$administration$basal, max_score)) {
          basal_start <- i
          break
        }
      }
      cursor <- lowest - 1L
    }
    if (!is.na(basal_start) && basal_start > 1L) {
      # Un blocco di inversione puo presentare item che finiscono sotto il
      # basale stabilito. Convenzione v0, coerente con la pratica corrente:
      # sotto il basale vale il credito pieno anche se l'item era stato
      # presentato. L'informazione non va persa e resta in un attributo.
      earlier <- seq_len(basal_start - 1L)
      presented_below_basal <- earlier[status[earlier] == "administered"]
      status[earlier] <- "below_basal"
    }
  } else if (start > 1L) {
    # Convenzione provvisoria v0: se la finestra iniziale non attiva
    # l'inversione, gli item precedenti ricevono credito pieno.
    status[seq_len(start - 1L)] <- "below_basal"
    basal_start <- start
  }

  # Il ceiling si valuta solo nella direzione normale, mai durante l'inversione.
  zero_limit <- as.integer(st$administration$ceiling$consecutive_items)
  zero_score <- as.numeric(st$administration$ceiling$item_score)
  zero_run <- 0L
  ceiling_item <- NA_integer_
  for (i in initial) {
    zero_run <- if (scores[i] == zero_score) zero_run + 1L else 0L
    if (zero_run >= zero_limit) ceiling_item <- i
  }

  next_item <- max(initial) + 1L
  if (is.na(ceiling_item) && next_item <= n_items) {
    for (i in seq.int(next_item, n_items)) {
      status[i] <- "administered"
      zero_run <- if (scores[i] == zero_score) zero_run + 1L else 0L
      if (zero_run >= zero_limit) {
        ceiling_item <- i
        break
      }
    }
  }
  if (!is.na(ceiling_item) && ceiling_item < n_items) {
    status[seq.int(ceiling_item + 1L, n_items)] <- "above_ceiling"
  }

  observed <- ifelse(status == "administered", scores, NA_real_)
  assigned <- ifelse(
    status == "below_basal", bii_full_credit(st),
    ifelse(status == "above_ceiling", 0, observed)
  )
  result <- data.frame(
    item_id = items$item_id,
    order = items$order,
    administration_status = status,
    observed_score = observed,
    assigned_score = assigned,
    stringsAsFactors = FALSE
  )
  attr(result, "subtest") <- subtest_id
  attr(result, "start_item") <- start
  attr(result, "inversion_applied") <- inversion
  attr(result, "basal_start") <- basal_start
  attr(result, "ceiling_item") <- ceiling_item
  attr(result, "presented_below_basal") <- presented_below_basal
  result
}

# Handler per route_type: delayed_retrieval.
# Insieme fisso, nessuna regola adattiva: tutti gli item vengono somministrati.
# Quello che cambia rispetto agli altri subtest non e il routing ma lo scoring,
# che deriva il punteggio da due componenti (recupero e riconoscimento).
bii_route_delayed_retrieval <- function(subtest_id, complete_scores, age_months, context) {
  st <- context$spec
  items <- context$items
  n_items <- nrow(items)

  scores <- suppressWarnings(as.numeric(complete_scores))
  allowed <- bii_item_scores(st)
  if (length(scores) != n_items || anyNA(scores) || any(!scores %in% allowed)) {
    stop(
      subtest_id, ": complete_scores deve contenere uno dei punteggi ",
      paste(allowed, collapse = "/"), " per ciascuno dei ", n_items, " item.",
      call. = FALSE
    )
  }
  # L'eta non seleziona item: serve solo a verificare che sia nel range.
  subtest_age_is_eligible(age_months, st, context$battery)

  result <- data.frame(
    item_id = items$item_id,
    order = items$order,
    administration_status = rep("administered", n_items),
    observed_score = scores,
    assigned_score = scores,
    stringsAsFactors = FALSE
  )
  attr(result, "subtest") <- subtest_id
  attr(result, "start_item") <- 1L
  attr(result, "inversion_applied") <- FALSE
  attr(result, "basal_start") <- NA_integer_
  attr(result, "ceiling_item") <- NA_integer_
  attr(result, "presented_below_basal") <- integer(0)
  result
}

# Verifica che l'eta sia nel range della batteria e in quello del subtest.
subtest_age_is_eligible <- function(age_months, st_spec, battery) {
  age_months <- suppressWarnings(as.integer(age_months))
  if (length(age_months) != 1L || is.na(age_months)) {
    stop("age_months deve contenere una sola eta valida in mesi.", call. = FALSE)
  }
  limits <- c(as.integer(battery$age_range_months$min), as.integer(battery$age_range_months$max))
  if (!is.null(st_spec$age_eligibility_months)) {
    limits <- as.integer(unlist(st_spec$age_eligibility_months, use.names = FALSE))
  }
  if (age_months < limits[1] || age_months > limits[2]) {
    stop(
      st_spec$id, ": eta ", age_months, " mesi fuori dal range previsto (",
      limits[1], "-", limits[2], ").", call. = FALSE
    )
  }
  invisible(TRUE)
}

# Livello di partenza per eta nei subtest a livelli: la spec dichiara una
# lunghezza di sequenza, non un indice di item.
subtest_start_level <- function(age_months, st_spec) {
  age_months <- suppressWarnings(as.integer(age_months))
  if (length(age_months) != 1L || is.na(age_months)) {
    stop("age_months deve contenere una sola eta valida in mesi.", call. = FALSE)
  }
  for (rule in st_spec$administration$start_points) {
    limits <- as.integer(unlist(rule$age_months, use.names = FALSE))
    if (age_months >= limits[1] && age_months <= limits[2]) {
      return(as.integer(rule$sequence_length))
    }
  }
  stop("Eta fuori dal range previsto dalla BII: ", age_months, " mesi.", call. = FALSE)
}

# Routing a livelli su un singolo blocco di item.
# La logica e deliberatamente la stessa di adaptive_items, con il livello al
# posto della finestra di item: stesso trigger separato dal basale, stessa
# convenzione generosa nella zona intermedia, stesso ceiling solo in avanti.
# Una sola procedura da imparare per l'esaminatore, non due.
bii_route_levels_block <- function(subtest_id, st, block, scores, start_level, max_score) {
  levels_present <- sort(unique(block$level))
  trials_per_level <- as.integer(st$administration$trials_per_level)
  status <- rep("not_administered", nrow(block))

  if (!start_level %in% levels_present) {
    stop(
      subtest_id, ": il livello di partenza ", start_level,
      " non esiste nell'item bank (livelli presenti: ",
      paste(levels_present, collapse = ", "), ").", call. = FALSE
    )
  }
  at_level <- function(value) which(block$level == value)
  n_correct <- function(idx) sum(scores[idx] >= max_score)
  n_errors <- function(idx) sum(scores[idx] < max_score)

  basal_needed <- as.integer(st$administration$basal$consecutive_correct)
  ceiling_needed <- as.integer(st$administration$ceiling$consecutive_errors)
  inversion_needed <- as.integer(st$administration$inversion$initial_consecutive_failures)

  start_idx <- at_level(start_level)
  status[start_idx] <- "administered"
  lower_levels <- levels_present[levels_present < start_level]

  inversion <- n_errors(start_idx) >= inversion_needed
  basal_level <- NA_integer_
  presented_below_basal <- integer(0)

  if (inversion && length(lower_levels)) {
    for (value in rev(lower_levels)) {
      idx <- at_level(value)
      status[idx] <- "administered"
      if (n_correct(idx) >= basal_needed) {
        basal_level <- value
        break
      }
    }
    if (!is.na(basal_level)) {
      below <- which(block$level < basal_level)
      presented_below_basal <- below[status[below] == "administered"]
      status[below] <- "below_basal"
    }
  } else if (length(lower_levels)) {
    # Convenzione v0, la stessa di adaptive_items: se il livello di partenza non
    # attiva l'inversione, i livelli piu bassi ricevono credito pieno.
    status[block$level < start_level] <- "below_basal"
    basal_level <- start_level
  } else {
    if (n_correct(start_idx) >= basal_needed) basal_level <- start_level
  }

  # Ceiling solo in avanti, valutato anche sul livello di partenza.
  ceiling_level <- NA_integer_
  if (n_errors(start_idx) >= ceiling_needed) {
    ceiling_level <- start_level
  } else {
    for (value in levels_present[levels_present > start_level]) {
      idx <- at_level(value)
      status[idx] <- "administered"
      if (n_errors(idx) >= ceiling_needed) {
        ceiling_level <- value
        break
      }
    }
  }
  if (!is.na(ceiling_level)) {
    status[block$level > ceiling_level] <- "above_ceiling"
  }

  list(
    status = status,
    basal_level = basal_level,
    ceiling_level = ceiling_level,
    inversion = inversion,
    presented_below_basal = presented_below_basal,
    trials_per_level = trials_per_level
  )
}

# Handler comune a adaptive_levels e adaptive_levels_by_microblock.
# Con i microblocchi la stessa procedura si applica a ciascuno in modo
# indipendente: ognuno ha il proprio basale e il proprio ceiling.
bii_route_levels <- function(subtest_id, complete_scores, age_months, context) {
  st <- context$spec
  items <- context$items
  n_items <- nrow(items)

  scores <- suppressWarnings(as.numeric(complete_scores))
  allowed <- bii_item_scores(st)
  if (length(scores) != n_items || anyNA(scores) || any(!scores %in% allowed)) {
    stop(
      subtest_id, ": complete_scores deve contenere uno dei punteggi ",
      paste(allowed, collapse = "/"), " per ciascuno dei ", n_items, " item.",
      call. = FALSE
    )
  }
  if (!"level" %in% names(items)) {
    stop(subtest_id, ": item bank a livelli senza colonna level.", call. = FALSE)
  }
  max_score <- max(allowed)
  start_level <- subtest_start_level(age_months, st)

  by_microblock <- identical(st$administration$route_type, "adaptive_levels_by_microblock")
  if (by_microblock && !"microblock" %in% names(items)) {
    stop(subtest_id, ": route_type per microblocco senza colonna microblock.", call. = FALSE)
  }
  groups <- if (by_microblock) items$microblock else rep("all", n_items)
  group_ids <- unique(groups)

  status <- rep(NA_character_, n_items)
  basal_level <- stats::setNames(rep(NA_integer_, length(group_ids)), group_ids)
  ceiling_level <- basal_level
  inversion <- stats::setNames(rep(FALSE, length(group_ids)), group_ids)
  presented <- integer(0)

  for (group in group_ids) {
    rows <- which(groups == group)
    routed <- bii_route_levels_block(
      subtest_id, st, items[rows, , drop = FALSE], scores[rows], start_level, max_score
    )
    status[rows] <- routed$status
    basal_level[[group]] <- routed$basal_level
    ceiling_level[[group]] <- routed$ceiling_level
    inversion[[group]] <- routed$inversion
    presented <- c(presented, rows[routed$presented_below_basal])
  }

  observed <- ifelse(status == "administered", scores, NA_real_)
  assigned <- ifelse(
    status == "below_basal", bii_full_credit(st),
    ifelse(status == "above_ceiling", 0, observed)
  )
  result <- data.frame(
    item_id = items$item_id,
    order = items$order,
    administration_status = status,
    observed_score = observed,
    assigned_score = assigned,
    stringsAsFactors = FALSE
  )
  attr(result, "subtest") <- subtest_id
  attr(result, "start_level") <- start_level
  attr(result, "inversion_applied") <- any(inversion)
  attr(result, "inversion_by_group") <- inversion
  attr(result, "basal_level") <- basal_level
  attr(result, "ceiling_level") <- ceiling_level
  attr(result, "presented_below_basal") <- sort(presented)
  # Attributi comuni a tutti gli handler, per il codice che li legge in modo
  # uniforme (simulazione, report di QA).
  attr(result, "start_item") <- min(items$order[items$level == start_level])
  attr(result, "basal_start") <- NA_integer_
  attr(result, "ceiling_item") <- if (all(is.na(ceiling_level))) NA_integer_ else 1L
  result
}

# Registro dei route type implementati. Aggiungere un route type significa
# scrivere un handler e registrarlo qui, non modificare route_subtest().
BII_ROUTE_HANDLERS <- list(
  adaptive_items = bii_route_adaptive_items,
  delayed_retrieval = bii_route_delayed_retrieval,
  adaptive_levels = bii_route_levels,
  adaptive_levels_by_microblock = bii_route_levels
)

# Scoring di un record reale: nessuna informazione sugli item non somministrati
# viene inventata, e gli stati esterni non diventano mai risposte errate.
score_subtest_record <- function(subtest_id, records, root = NULL, context = NULL) {
  if (is.null(context)) context <- load_item_bank(subtest_id, root)
  st <- context$spec
  items <- context$items

  derived_from <- unlist(st$scoring$derived_from, use.names = FALSE)
  required <- c("item_id", "administration_status", if (is.null(derived_from)) "item_score" else derived_from)
  missing <- setdiff(required, names(records))
  if (length(missing)) stop("Colonne mancanti: ", paste(missing, collapse = ", "), call. = FALSE)

  records <- records[records$item_id %in% items$item_id, , drop = FALSE]
  if (nrow(records) != nrow(items) || anyDuplicated(records$item_id) ||
      !setequal(records$item_id, items$item_id)) {
    stop(
      subtest_id, ": il record deve contenere una volta ciascuno dei ",
      nrow(items), " item scored.", call. = FALSE
    )
  }
  records <- records[match(items$item_id, records$item_id), , drop = FALSE]

  records$administration_status <- trimws(as.character(records$administration_status))
  if (any(!records$administration_status %in% BII_RESPONSE_STATUSES)) {
    bad <- setdiff(unique(records$administration_status), BII_RESPONSE_STATUSES)
    stop(
      subtest_id, ": administration_status non valido: ",
      paste(bad, collapse = ", "), ".", call. = FALSE
    )
  }

  administered <- records$administration_status == "administered"
  if (!is.null(derived_from)) {
    # Il punteggio di item non e registrato: si deriva dalle componenti.
    records$item_score <- bii_derive_component_scores(subtest_id, records, st, administered)
  }
  recorded <- suppressWarnings(as.numeric(records$item_score))
  allowed <- bii_item_scores(st)
  if (any(is.na(recorded[administered])) || any(!recorded[administered] %in% allowed)) {
    stop(
      subtest_id, ": gli item administered richiedono item_score ",
      paste(allowed, collapse = "/"), ".", call. = FALSE
    )
  }

  assigned <- rep(NA_real_, nrow(records))
  assigned[administered] <- recorded[administered]
  assigned[records$administration_status == "omitted"] <- 0
  assigned[records$administration_status == "below_basal"] <- bii_full_credit(st)
  assigned[records$administration_status == "above_ceiling"] <- 0
  blocking <- records$administration_status %in% c("external_missing", "invalidated")
  valid <- !any(blocking)

  records$assigned_score <- assigned
  raw <- if (valid) sum(assigned) else NA_real_
  raw_max <- as.numeric(st$scoring$raw_max)
  if (valid && (raw < as.numeric(st$scoring$raw_min) || raw > raw_max)) {
    stop(subtest_id, ": punteggio grezzo fuori dal range dichiarato nella spec.", call. = FALSE)
  }

  list(
    subtest = subtest_id,
    items = records,
    raw_score = raw,
    raw_max = raw_max,
    valid = valid,
    reason = if (valid) "complete" else "external_missing_or_invalidated",
    warnings = bii_record_warnings(records, st)
  )
}

# Punteggio di item derivato da componenti osservate.
#
# Le condizioni hanno nomi che il motore conosce; quale punteggio spetta a
# ciascuna e dichiarato nella spec (`scoring.rubric`), quindi cambiarlo non
# richiede di toccare il codice.
bii_derive_component_scores <- function(subtest_id, records, st_spec, administered) {
  rubric <- st_spec$scoring$rubric
  if (is.null(rubric)) {
    stop(subtest_id, ": scoring.derived_from senza scoring.rubric nella spec.", call. = FALSE)
  }
  # rubric e una mappa punteggio -> nome della condizione; serve l'inverso.
  score_for <- stats::setNames(as.numeric(names(rubric)), unlist(rubric, use.names = FALSE))

  components <- st_spec$scoring$components
  for (component in names(components)) {
    values <- unlist(components[[component]], use.names = FALSE)
    observed <- trimws(as.character(records[[component]]))
    bad <- setdiff(unique(observed[administered]), values)
    if (length(bad)) {
      stop(
        subtest_id, ": valori non ammessi nella componente ", component, ": ",
        paste(bad, collapse = ", "), ". Ammessi: ", paste(values, collapse = ", "), ".",
        call. = FALSE
      )
    }
    records[[component]] <- observed
  }

  recall <- records$recall
  recognition <- records$recognition

  # Il riconoscimento si somministra solo dopo un recupero non riuscito. Se
  # manca dove servirebbe, il record e incompleto: non si inventa uno zero.
  needs_recognition <- administered & recall != "correct"
  if (any(needs_recognition & recognition == "not_administered")) {
    missing_ids <- records$item_id[needs_recognition & recognition == "not_administered"]
    stop(
      subtest_id, ": recupero non riuscito senza riconoscimento somministrato per ",
      paste(missing_ids, collapse = ", "),
      ". Il record e incompleto e il punteggio non viene inventato.", call. = FALSE
    )
  }

  scores <- rep(NA_real_, nrow(records))
  scores[administered & recall == "correct"] <- score_for[["correct_cued_recall"]]
  scores[needs_recognition & recognition == "correct"] <-
    score_for[["correct_recognition_after_incorrect_or_omitted_recall"]]
  scores[needs_recognition & recognition == "incorrect"] <-
    score_for[["incorrect_recognition"]]
  scores
}

# Avvisi procedurali: non bloccano il calcolo, segnalano procedure improbabili.
bii_record_warnings <- function(records, st_spec) {
  out <- character()
  status <- records$administration_status
  n <- length(status)
  administered_idx <- which(status == "administered")
  if (length(administered_idx) == 0L) {
    out <- c(out, "Nessun item risulta somministrato.")
  } else {
    below <- which(status == "below_basal")
    above <- which(status == "above_ceiling")
    if (length(below) && max(below) > min(administered_idx)) {
      out <- c(out, "Item sotto basale collocati dopo item somministrati.")
    }
    if (length(above) && min(above) < max(administered_idx)) {
      out <- c(out, "Item sopra ceiling collocati prima di item somministrati.")
    }
  }
  # Il ritardo effettivo del recupero differito e un dato procedurale, non un
  # punteggio: fuori finestra si avvisa, non si rifiuta il calcolo.
  window <- unlist(st_spec$administration$retrieval_window_minutes, use.names = FALSE)
  if (length(window) == 2L) {
    if (!"delay_minutes" %in% names(records)) {
      out <- c(out, "Ritardo effettivo del recupero non registrato.")
    } else {
      delay <- suppressWarnings(as.numeric(records$delay_minutes))
      delay <- unique(delay[!is.na(delay)])
      if (length(delay) == 0L) {
        out <- c(out, "Ritardo effettivo del recupero non registrato.")
      } else if (length(delay) > 1L) {
        out <- c(out, "Ritardo del recupero incoerente fra le righe del record.")
      } else if (delay < window[1] || delay > window[2]) {
        out <- c(out, sprintf(
          "Recupero differito a %g minuti, fuori dalla finestra prevista di %g-%g minuti.",
          delay, window[1], window[2]
        ))
      }
    }
  }

  zero_limit <- as.integer(st_spec$administration$ceiling$consecutive_items)
  if (length(zero_limit) == 1L && !is.na(zero_limit) && length(administered_idx) > 0L) {
    scored <- records$assigned_score
    run <- 0L
    for (i in seq_len(n)) {
      if (identical(status[i], "administered") && !is.na(scored[i]) && scored[i] == 0) {
        run <- run + 1L
      } else {
        run <- 0L
      }
      if (run > zero_limit) {
        out <- c(out, "La regola di interruzione sembra non essere stata applicata.")
        break
      }
    }
  }
  out
}
