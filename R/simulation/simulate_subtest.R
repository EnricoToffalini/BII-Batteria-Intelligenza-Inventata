# Simulazione item-level generica per i subtest adattivi per item.
#
# Serve a controllare che le regole adattive dichiarate nella spec si
# comportino in modo plausibile: quanti item vengono somministrati, quanto
# spesso scatta l'inversione, quanto spesso si tocca il ceiling, se il
# punteggio grezzo va a fondo o a soffitto.
#
# NON produce norme e non e una calibrazione empirica. I difficulty_target
# dell'item bank sono ipotesi progettuali, non parametri stimati.

if (!exists("route_subtest", mode = "function")) {
  .bii_sim_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(.bii_sim_root, "R", "scoring", "administer.R"))) break
    .bii_sim_parent <- dirname(.bii_sim_root)
    if (identical(.bii_sim_parent, .bii_sim_root)) stop("Repository BII non trovato.", call. = FALSE)
    .bii_sim_root <- .bii_sim_parent
  }
  source(file.path(.bii_sim_root, "R", "scoring", "administer.R"), local = TRUE)
}

# Parametri del modello generativo, tenuti espliciti e in un unico posto.
# Sono scelte didattiche dichiarate, non stime.
BII_SIM_PARAMS <- list(
  ability_mean_youngest = -1.1,
  ability_mean_gain_over_range = 2.2,
  ability_sd = 0.9,
  slope = 1.2,
  threshold_step = 0.55
)

# Campione latente condiviso: eta uniforme nel range della batteria e abilita
# che cresce linearmente con l'eta. Usare la stessa funzione per tutti i
# subtest tiene le simulazioni sulla stessa scala latente.
simulate_population <- function(n, battery, params = BII_SIM_PARAMS) {
  age_min <- as.integer(battery$age_range_months$min)
  age_max <- as.integer(battery$age_range_months$max)
  age_months <- sample(age_min:age_max, n, replace = TRUE)
  age_position <- (age_months - age_min) / (age_max - age_min)
  ability <- stats::rnorm(
    n,
    mean = params$ability_mean_youngest + params$ability_mean_gain_over_range * age_position,
    sd = params$ability_sd
  )
  data.frame(age_months = age_months, latent_ability = ability, stringsAsFactors = FALSE)
}

# Soglie di un item politomico 0..max, centrate sul difficulty_target.
# Con max = 1 si riduce a una singola soglia, cioe al caso dicotomico.
bii_item_thresholds <- function(difficulty, max_score, step) {
  difficulty + step * (2 * seq_len(max_score) - max_score - 1)
}

# Punteggi che si osserverebbero somministrando ogni item a ogni soggetto.
simulate_complete_responses <- function(ability, difficulty, max_score, params = BII_SIM_PARAMS) {
  n <- length(ability)
  out <- matrix(0, nrow = n, ncol = length(difficulty))
  for (j in seq_along(difficulty)) {
    thresholds <- bii_item_thresholds(difficulty[j], max_score, params$threshold_step)
    probs <- vapply(
      thresholds,
      function(b) stats::plogis(params$slope * (ability - b)),
      numeric(n)
    )
    probs <- matrix(probs, nrow = n)
    draw <- stats::runif(n)
    score <- rep(0, n)
    for (k in seq.int(max_score, 1L)) {
      score <- ifelse(score == 0 & draw < probs[, k], k, score)
    }
    out[, j] <- score
  }
  out
}

simulate_subtest <- function(subtest_id, n = 500L, seed = 20260912L, root = NULL,
                             params = BII_SIM_PARAMS) {
  n <- suppressWarnings(as.integer(n))
  if (length(n) != 1L || is.na(n) || n < 1L) stop("n deve essere un intero positivo.", call. = FALSE)
  context <- load_item_bank(subtest_id, root)
  difficulty <- suppressWarnings(as.numeric(context$items$difficulty_target))
  if (anyNA(difficulty)) {
    stop(subtest_id, ": difficulty_target mancante nell'item bank.", call. = FALSE)
  }
  max_score <- max(bii_item_scores(context$spec))

  set.seed(seed)
  population <- simulate_population(n, context$battery, params)
  complete <- simulate_complete_responses(population$latent_ability, difficulty, max_score, params)

  routed <- lapply(
    seq_len(n),
    function(i) route_subtest(subtest_id, complete[i, ], population$age_months[i], context = context)
  )

  data.frame(
    simulated_id = sprintf("SIM-%04d", seq_len(n)),
    subtest = subtest_id,
    age_months = population$age_months,
    latent_ability = population$latent_ability,
    full_score = rowSums(complete),
    raw_score = vapply(routed, function(x) sum(x$assigned_score), numeric(1)),
    n_administered = vapply(routed, function(x) sum(x$administration_status == "administered"), integer(1)),
    inversion_applied = vapply(routed, function(x) isTRUE(attr(x, "inversion_applied")), logical(1)),
    ceiling_reached = vapply(routed, function(x) !is.na(attr(x, "ceiling_item")), logical(1)),
    data_source = "simulated",
    stringsAsFactors = FALSE
  )
}

# Diagnostica di routing richiesta dalla fase 4 della roadmap.
summarise_subtest_simulation <- function(x, root = NULL) {
  context <- load_item_bank(unique(x$subtest)[1], root)
  raw_max <- as.numeric(context$spec$scoring$raw_max)
  n_items <- nrow(context$items)
  younger <- x$age_months < stats::median(x$age_months)
  data.frame(
    subtest = unique(x$subtest)[1],
    n = nrow(x),
    n_items = n_items,
    mean_raw = mean(x$raw_score),
    sd_raw = stats::sd(x$raw_score),
    mean_raw_younger = mean(x$raw_score[younger]),
    mean_raw_older = mean(x$raw_score[!younger]),
    mean_items_administered = mean(x$n_administered),
    inversion_rate = mean(x$inversion_applied),
    ceiling_rate = mean(x$ceiling_reached),
    floor_rate = mean(x$raw_score == 0),
    at_raw_max_rate = mean(x$raw_score == raw_max),
    # Scarto fra punteggio dopo routing e punteggio a somministrazione completa:
    # quantifica l'informazione persa dalle regole adattive.
    mean_routing_bias = mean(x$raw_score - x$full_score),
    stringsAsFactors = FALSE
  )
}

# Report compatto su tutti i subtest che hanno gia un item bank.
simulate_all_available <- function(n = 500L, seed = 20260912L, root = NULL) {
  ids <- subtests_with_item_bank(root)
  rows <- list()
  for (id in ids) {
    context <- load_item_bank(id, root)
    # Si simulano tutti i route type implementati, non solo adaptive_items.
    if (is.null(BII_ROUTE_HANDLERS[[context$spec$administration$route_type]])) next
    simulated <- simulate_subtest(id, n = n, seed = seed, root = root)
    rows[[id]] <- summarise_subtest_simulation(simulated, root)
  }
  if (length(rows) == 0L) return(NULL)
  do.call(rbind, rows)
}

if (sys.nframe() == 0L) {
  report <- simulate_all_available()
  print(report, row.names = FALSE)
  message("Output simulato: controllo tecnico delle regole adattive, non norme empiriche.")
}
