# Amministrazioni sintetiche complete per ogni subtest con item bank.
#
# Percorso verificato, uguale per tutte le classi di route:
#   risposte complete -> route_subtest() -> modulo di registrazione versionato
#   compilato come farebbe l'esaminatore -> score_subtest_record()
#   -> file di dati raccolti controllato da R/data/check_responses.R.
#
# Nessun ID di subtest e scritto qui: i casi si ricavano da spec e item bank,
# quindi un nuovo subtest con item bank entra nel test senza modifiche.
# Le risposte simulate sono un controllo tecnico, non dati normativi.

source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)
source(file.path(root, "R", "simulation", "simulate_subtest.R"), local = TRUE)

# check_responses.R definisce un proprio load_item_bank(): ambiente separato.
data_checker <- new.env(parent = globalenv())
sys.source(file.path(root, "R", "data", "check_responses.R"), envir = data_checker)

spec <- bii_spec(root)
ids <- subtests_with_item_bank(root, spec)
stopifnot(length(ids) > 0L)

# Condizioni di scoring derivato note al motore -> componenti da registrare.
# Il punteggio di ciascuna condizione resta quello dichiarato nella spec.
# Per il recupero non riuscito si alternano "incorrect" e "omitted".
derived_components <- list(
  correct_cued_recall = list(recall = "correct", recognition = "not_administered"),
  correct_recognition_after_incorrect_or_omitted_recall = list(recall = c("incorrect", "omitted"), recognition = "correct"),
  incorrect_recognition = list(recall = c("omitted", "incorrect"), recognition = "incorrect")
)

read_record_form <- function(id) {
  utils::read.csv(
    file.path(root, "materials", "record_forms", paste0(id, "_record_form.csv")),
    stringsAsFactors = FALSE, check.names = FALSE, colClasses = "character"
  )
}

# Compila il modulo a partire dall'esito del routing: stato per ogni item,
# punteggio (o componenti) solo per gli item somministrati, pratica eseguita.
fill_record_form <- function(form, routed, subject_id, age, context) {
  form$subject_id <- subject_id
  form$age_months <- as.character(age)
  form$administration_status[form$item_type == "practice"] <- "administered"
  rows <- match(routed$item_id, form$item_id)
  stopifnot(!anyNA(rows))
  form$administration_status[rows] <- routed$administration_status
  administered <- routed$administration_status == "administered"
  observed <- routed$observed_score

  rubric <- context$spec$scoring$rubric
  if (is.null(context$spec$scoring$derived_from)) {
    form$item_score[rows[administered]] <- as.character(observed[administered])
  } else {
    for (k in which(administered)) {
      condition <- rubric[[as.character(observed[k])]]
      parts <- derived_components[[condition]]
      stopifnot(!is.null(parts))
      for (component in names(parts)) {
        values <- parts[[component]]
        form[[component]][rows[k]] <- values[(k - 1L) %% length(values) + 1L]
      }
    }
  }
  window <- unlist(context$spec$administration$retrieval_window_minutes, use.names = FALSE)
  if (length(window) == 2L) form$delay_minutes <- as.character(mean(window))
  form
}

# Eta ai bordi di ogni fascia di partenza, oppure ai bordi del range.
boundary_ages <- function(st) {
  bands <- lapply(st$administration$start_points, function(rule) as.integer(unlist(rule$age_months)))
  if (!length(bands)) {
    bands <- list(c(as.integer(spec$battery$age_range_months$min), as.integer(spec$battery$age_range_months$max)))
  }
  sort(unique(unlist(bands)))
}

n_simulated <- 120L
covered_routes <- character()

for (id in ids) {
  context <- load_item_bank(id, root, spec)
  st <- context$spec
  route_type <- st$administration$route_type
  covered_routes <- c(covered_routes, route_type)
  n_items <- nrow(context$items)
  scores <- bii_item_scores(st)
  form <- read_record_form(id)
  raw_min <- as.numeric(st$scoring$raw_min)
  raw_max <- as.numeric(st$scoring$raw_max)

  # Profili deterministici ai bordi di ogni fascia d'eta, piu risposte
  # simulate con seed fisso su tutto il range.
  ages <- boundary_ages(st)
  cases <- c(
    lapply(ages, function(a) list(age = a, scores = rep(max(scores), n_items), expect = raw_max)),
    lapply(ages, function(a) list(age = a, scores = rep(min(scores), n_items), expect = raw_min))
  )
  set.seed(20260926L)
  population <- simulate_population(n_simulated, spec$battery)
  complete <- simulate_complete_responses(
    population$latent_ability, as.numeric(context$items$difficulty_target), max(scores)
  )
  for (i in seq_len(n_simulated)) {
    cases[[length(cases) + 1L]] <- list(age = population$age_months[i], scores = complete[i, ], expect = NA_real_)
  }

  collected <- vector("list", length(cases))
  for (k in seq_along(cases)) {
    case <- cases[[k]]
    label <- sprintf("%s caso %d (eta %d)", id, k, case$age)
    routed <- route_subtest(id, case$scores, case$age, context = context)
    if (any(!routed$administration_status %in% BII_RESPONSE_STATUSES)) {
      stop(label, ": il routing ha prodotto uno stato non registrabile.")
    }
    routed_raw <- sum(routed$assigned_score)
    if (!is.na(case$expect) && routed_raw != case$expect) {
      stop(label, ": profilo estremo con grezzo ", routed_raw, " invece di ", case$expect, ".")
    }

    record <- fill_record_form(form, routed, sprintf("SIM-%04d", k), case$age, context)
    scored <- score_subtest_record(id, record, context = context)
    if (!isTRUE(scored$valid) || scored$raw_score != routed_raw) {
      stop(label, ": il modulo compilato non riproduce il punteggio del routing.")
    }
    if (scored$raw_score < raw_min || scored$raw_score > raw_max) {
      stop(label, ": grezzo fuori dal range della spec.")
    }
    # Una procedura applicata correttamente non deve generare avvisi.
    if (length(scored$warnings)) {
      stop(label, ": avvisi su una somministrazione corretta: ", paste(scored$warnings, collapse = " | "))
    }
    collected[[k]] <- record
  }

  # Lo stesso materiale, riportato nel file dei dati raccolti, supera il
  # controllo strutturale. Le componenti derivate restano nel file: per CR il
  # checker verifica anche che ogni protocollo completo sia correggibile.
  stacked <- do.call(rbind, collected)
  responses <- data.frame(
    subject_id = stacked$subject_id,
    age_months = stacked$age_months,
    subtest = stacked$subtest,
    item_id = stacked$item_id,
    administration_status = stacked$administration_status,
    response = "",
    item_score = if ("item_score" %in% names(stacked)) stacked$item_score else "",
    recall = if ("recall" %in% names(stacked)) stacked$recall else "",
    recognition = if ("recognition" %in% names(stacked)) stacked$recognition else "",
    delay_minutes = if ("delay_minutes" %in% names(stacked)) stacked$delay_minutes else "",
    response_time_seconds = "",
    notes = "",
    stringsAsFactors = FALSE
  )
  stopifnot(identical(names(responses), data_checker$response_columns))
  responses_path <- tempfile(fileext = ".csv")
  utils::write.csv(responses, responses_path, row.names = FALSE, na = "")
  stopifnot(nrow(data_checker$check_response_file(responses_path, root = root)) == nrow(responses))
}

# Ogni route type item-level implementato e usato da almeno un item bank viene
# coperto; fixed_time ha il proprio percorso aggregato in test_timed_records.R.
stopifnot(setequal(unique(covered_routes), setdiff(names(BII_ROUTE_HANDLERS), "fixed_time")))

# --- gli avvisi restano sensibili alle procedure davvero scorrette ------------

# adaptive_items: proseguire oltre il ceiling nella direzione normale.
for (id in ids) {
  context <- load_item_bank(id, root, spec)
  st <- context$spec
  if (!identical(st$administration$route_type, "adaptive_items")) next
  oldest <- max(boundary_ages(st))
  start <- subtest_start_item(oldest, st)
  limit <- as.integer(st$administration$ceiling$consecutive_items)
  n_items <- nrow(context$items)
  stopifnot(start + limit <= n_items)
  record <- data.frame(
    item_id = context$items$item_id,
    age_months = oldest,
    administration_status = ifelse(seq_len(n_items) < start, "below_basal", "administered"),
    item_score = ifelse(seq_len(n_items) < start, NA, 0),
    stringsAsFactors = FALSE
  )
  scored <- score_subtest_record(id, record, context = context)
  if (!any(grepl("interruzione", scored$warnings))) {
    stop(id, ": ceiling ignorato in avanti senza avviso.")
  }
}

# Microblocchi: l'ordine degli stati si controlla dentro ciascun microblocco.
for (id in ids) {
  context <- load_item_bank(id, root, spec)
  if (!identical(context$spec$administration$route_type, "adaptive_levels_by_microblock")) next
  items <- context$items
  first_block <- which(items$microblock == items$microblock[1])
  status <- rep("administered", nrow(items))
  status[first_block[1]] <- "above_ceiling"
  record <- data.frame(
    item_id = items$item_id,
    administration_status = status,
    item_score = ifelse(status == "administered", 1, NA),
    stringsAsFactors = FALSE
  )
  scored <- score_subtest_record(id, record, context = context)
  if (!any(grepl("sopra ceiling collocati prima", scored$warnings))) {
    stop(id, ": ceiling fuori ordine dentro un microblocco senza avviso.")
  }
}
