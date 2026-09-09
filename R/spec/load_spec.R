# BII structured specification loader and semantic validator.
# yaml is deliberately the only dependency: validation is executable in a
# clean R session without coupling this repository to a schema framework.

find_bii_root <- function(start = getwd()) {
  path <- normalizePath(start, winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(path, "spec", "battery.yml"))) return(path)
    parent <- dirname(path)
    if (identical(parent, path)) break
    path <- parent
  }
  stop("Impossibile trovare spec/battery.yml a partire da: ", start)
}

read_yaml_utf8 <- function(path) {
  yaml::yaml.load(paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n"))
}

read_bii_spec <- function(root = find_bii_root()) {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("Il pacchetto R 'yaml' è richiesto per leggere la spec BII.")
  }
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  battery <- read_yaml_utf8(file.path(root, "spec", "battery.yml"))
  files <- sort(list.files(file.path(root, "spec", "subtests"), pattern = "\\.ya?ml$", full.names = TRUE))
  if (length(files) == 0L) stop("Nessuna spec di subtest trovata in spec/subtests/.")
  subtests <- lapply(files, read_yaml_utf8)
  ids <- vapply(subtests, `[[`, character(1), "id")
  names(subtests) <- ids
  out <- list(root = root, battery = battery, subtests = subtests)
  validate_bii_spec(out)
  out
}

spec_error <- function(...) stop(paste0(...), call. = FALSE)

as_int <- function(x, field) {
  value <- suppressWarnings(as.integer(x))
  if (length(value) != 1L || is.na(value)) spec_error("Valore intero non valido per ", field, ".")
  value
}

validate_bii_spec <- function(spec) {
  battery <- spec$battery
  subtests <- spec$subtests
  required_battery <- c("schema_version", "battery_id", "version", "age_range_months", "n_subtests", "subtest_order", "roles", "domains", "norming", "indices", "quotients", "administration")
  missing_battery <- setdiff(required_battery, names(battery))
  if (length(missing_battery)) spec_error("battery.yml: campi mancanti: ", paste(missing_battery, collapse = ", "))
  if (!identical(battery$battery_id, "BII")) spec_error("battery.yml: battery_id deve essere BII.")

  age_min <- as_int(battery$age_range_months$min, "age_range_months.min")
  age_max <- as_int(battery$age_range_months$max, "age_range_months.max")
  if (age_min < 0L || age_max < age_min) spec_error("battery.yml: range di età non valido.")
  for (group in battery$norming$index_age_groups) {
    group_min <- as_int(group$min_months, "norming.index_age_groups.min_months")
    group_max <- as_int(group$max_months, "norming.index_age_groups.max_months")
    if (group_min < age_min || group_max > age_max || group_max < group_min) spec_error("battery.yml: gruppo età indici non valido.")
  }

  order_ids <- unlist(battery$subtest_order, use.names = FALSE)
  file_ids <- names(subtests)
  if (anyDuplicated(file_ids)) spec_error("Spec subtest: ID duplicati.")
  if (length(file_ids) != as_int(battery$n_subtests, "n_subtests")) spec_error("Numero di file subtest incoerente con n_subtests.")
  if (!setequal(order_ids, file_ids) || anyDuplicated(order_ids)) spec_error("subtest_order non coincide con gli ID dei file subtest.")

  roles <- names(battery$roles)
  domains <- names(battery$domains)
  for (id in file_ids) {
    st <- subtests[[id]]
    required_subtest <- c("id", "name", "domain", "role", "contributes_to", "response_format", "stimulus_mode", "construct", "item_ordering", "n_scored_items", "n_practice_items", "scoring", "timing", "administration")
    missing_subtest <- setdiff(required_subtest, names(st))
    if (length(missing_subtest)) spec_error(id, ": campi mancanti: ", paste(missing_subtest, collapse = ", "))
    if (!identical(st$id, id) || !grepl("^[A-Z]{2}$", id)) spec_error(id, ": ID non valido.")
    if (!st$domain %in% domains) spec_error(id, ": dominio sconosciuto ", st$domain, ".")
    if (!st$role %in% roles) spec_error(id, ": ruolo sconosciuto ", st$role, ".")
    n_items <- as_int(st$n_scored_items, paste0(id, ".n_scored_items"))
    if (n_items < 1L || as_int(st$n_practice_items, paste0(id, ".n_practice_items")) < 0L) spec_error(id, ": numero item non valido.")
    raw_min <- as_int(st$scoring$raw_min, paste0(id, ".scoring.raw_min"))
    raw_max <- as_int(st$scoring$raw_max, paste0(id, ".scoring.raw_max"))
    if (raw_min != 0L || raw_max < raw_min) spec_error(id, ": range grezzo non valido.")
    if (st$scoring$type %in% c("dichotomous", "polytomous")) {
      scores <- as.integer(unlist(st$scoring$item_scores, use.names = FALSE))
      if (!identical(min(scores), 0L) || max(scores) < 1L || raw_max != n_items * max(scores)) {
        spec_error(id, ": raw_max incompatibile con numero item e scoring.")
      }
    }
    route_type <- st$administration$route_type
    if (route_type %in% c("adaptive_items", "adaptive_levels", "adaptive_levels_by_microblock")) {
      starts <- st$administration$start_points
      if (length(starts) == 0L) spec_error(id, ": start_points mancanti.")
      for (start in starts) {
        span <- as.integer(unlist(start$age_months, use.names = FALSE))
        if (length(span) != 2L || span[1] > span[2] || span[1] < age_min || span[2] > age_max) spec_error(id, ": start point con età fuori range.")
        if (!is.null(start$item) && (start$item < 1L || start$item > n_items)) spec_error(id, ": start item fuori range.")
      }
    }
  }

  core_ids <- file_ids[vapply(subtests, function(x) identical(x$role, "core"), logical(1))]
  qi_total <- unlist(battery$quotients$QI_totale$components, use.names = FALSE)
  if (!setequal(core_ids, qi_total)) spec_error("QI_totale deve includere esattamente tutti i subtest core.")

  for (index_id in names(battery$indices)) {
    index <- battery$indices[[index_id]]
    if (!index$domain %in% domains) spec_error(index_id, ": dominio indice sconosciuto.")
    component_ids <- unlist(index$modes, use.names = FALSE)
    if (!all(component_ids %in% file_ids)) spec_error(index_id, ": componente indice sconosciuta.")
    if (!is.null(index$supplementary) && !all(unlist(index$supplementary) %in% file_ids)) spec_error(index_id, ": supplementare indice sconosciuto.")
  }
  for (quotient_id in names(battery$quotients)) {
    ids <- unlist(battery$quotients[[quotient_id]]$components, use.names = FALSE)
    if (length(ids) < 2L || anyDuplicated(ids) || !all(ids %in% file_ids)) spec_error(quotient_id, ": componenti non valide.")
  }
  invisible(TRUE)
}

spec_subtest_table <- function(spec) {
  ids <- spec$battery$subtest_order
  data.frame(
    id = ids,
    name = vapply(spec$subtests[ids], `[[`, character(1), "name"),
    domain = vapply(spec$subtests[ids], `[[`, character(1), "domain"),
    role = vapply(spec$subtests[ids], `[[`, character(1), "role"),
    raw_min = vapply(spec$subtests[ids], function(x) as.integer(x$scoring$raw_min), integer(1)),
    raw_max = vapply(spec$subtests[ids], function(x) as.integer(x$scoring$raw_max), integer(1)),
    stringsAsFactors = FALSE
  )
}
