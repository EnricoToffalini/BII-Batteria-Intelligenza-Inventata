# Controlli di coerenza fra spec, item bank e artefatti derivati.
# Chiude i controlli minimi previsti dalla fase 0 della roadmap: file mancanti,
# ID duplicati, range incompatibili, riferimenti a risorse inesistenti.

source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)
source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)
source(file.path(root, "R", "build", "build_record_forms.R"), local = TRUE)

spec <- read_bii_spec(root)
banked <- subtests_with_item_bank(root, spec)
stopifnot(length(banked) > 0L)

# --- riferimenti a risorse: file e ancore devono esistere ---------------------

# Slug in stile GitHub, per verificare che `file.md#ancora` punti a un titolo
# realmente presente e non a un'ancora scritta a memoria.
md_slug <- function(heading) {
  x <- tolower(trimws(sub("^#+\\s*", "", heading)))
  x <- gsub("[^[:alnum:][:space:]-]", "", x)
  gsub("\\s+", "-", trimws(x))
}

for (id in banked) {
  context <- load_item_bank(id, root, spec)
  all_items <- rbind(context$practice, context$items)
  for (ref in unique(all_items$rubric_ref)) {
    if (!nzchar(ref)) stop(id, ": rubric_ref vuoto.")
    path <- sub("#.*$", "", ref)
    anchor <- sub("^[^#]*#?", "", ref)
    full <- file.path(root, path)
    if (!file.exists(full)) stop(id, ": rubrica non trovata: ", path)
    if (nzchar(anchor)) {
      lines <- readLines(full, encoding = "UTF-8", warn = FALSE)
      anchors <- md_slug(grep("^#+\\s", lines, value = TRUE))
      if (!anchor %in% anchors) {
        stop(id, ": ancora '", anchor, "' assente in ", path, ".")
      }
    }
  }
}

# --- coerenza fra spec, item bank e range grezzo ------------------------------

for (id in banked) {
  context <- load_item_bank(id, root, spec)
  st <- context$spec
  n_current <- nrow(context$items)
  max_points <- max(bii_item_scores(st))
  declared <- as.integer(st$item_bank$n_scored_items_current)

  if (!identical(n_current, declared)) {
    stop(id, ": n_scored_items_current dichiara ", declared, " item ma il CSV ne ha ", n_current, ".")
  }
  if (n_current > as.integer(st$n_scored_items)) {
    stop(id, ": l'item bank supera n_scored_items dichiarato nella spec.")
  }
  if (as.integer(st$scoring$raw_max) != as.integer(st$n_scored_items) * max_points) {
    stop(id, ": raw_max incompatibile con n_scored_items e punteggio massimo di item.")
  }
  # Il totale ottenibile dagli item presenti non deve superare il range grezzo.
  if (n_current * max_points > as.integer(st$scoring$raw_max)) {
    stop(id, ": gli item presenti permettono di superare raw_max.")
  }
  # Uno stato complete_draft dichiara una forma completa: i due numeri devono
  # coincidere, altrimenti la spec promette piu di quello che esiste.
  if (identical(st$item_bank$status, "complete_draft") &&
      !identical(n_current, as.integer(st$n_scored_items))) {
    stop(id, ": item bank dichiarato complete_draft ma incompleto.")
  }
}

# --- i moduli di registrazione sono artefatti derivati ------------------------

form_ids <- record_form_subtests(root)
timed_ids <- spec$battery$subtest_order[vapply(
  spec$subtests[spec$battery$subtest_order],
  function(st) identical(st$administration$route_type, "fixed_time"),
  logical(1)
)]
stopifnot(
  all(banked %in% form_ids),
  setequal(setdiff(form_ids, banked), timed_ids),
  identical(form_ids, spec$battery$subtest_order[spec$battery$subtest_order %in% form_ids])
)

for (id in form_ids) {
  path <- record_form_path(id, root)
  if (!file.exists(path)) stop(id, ": modulo di registrazione mancante.")
  # Il confronto avviene in memoria: il test non riscrive mai il file.
  if (!identical(readLines(path, warn = FALSE), record_form_lines(id, root))) {
    stop(
      id, ": il modulo di registrazione non corrisponde all'item bank. ",
      "Rigenerarlo con Rscript R/build/build_record_forms.R."
    )
  }
}

# --- ogni item bank ha un piano di progettazione ------------------------------

# Il piano dice che cosa il subtest deve e non deve diventare. Senza di esso chi
# sostituisce un item non sa quali vincoli stava rispettando l'originale.
for (id in banked) {
  design <- file.path(root, "items", "design", paste0(id, ".md"))
  if (!file.exists(design)) stop(id, ": manca items/design/", id, ".md.")
  text <- readLines(design, encoding = "UTF-8", warn = FALSE)
  if (!any(grepl("^## Punti aperti|^## Stato", text))) {
    stop(id, ": il piano di progettazione non dichiara i punti aperti.")
  }
}

# --- il manuale copre i subtest dichiarati completi ---------------------------

manual <- readLines(file.path(root, "manual", "ADMINISTRATION.md"), encoding = "UTF-8", warn = FALSE)
for (id in banked) {
  st <- spec$subtests[[id]]
  if (!identical(st$item_bank$status, "complete_draft")) next
  if (!any(grepl(paste0("^# ", id, " "), manual))) {
    stop(id, ": item bank completo ma sezione assente in manual/ADMINISTRATION.md.")
  }
}

# --- provenienza dichiarata per ogni item bank --------------------------------

provenance <- readLines(file.path(root, "items", "PROVENANCE.md"), encoding = "UTF-8", warn = FALSE)
for (id in banked) {
  if (!any(grepl(paste0("`", id, ".csv`"), provenance, fixed = TRUE))) {
    stop(id, ": item bank senza riga di provenienza in items/PROVENANCE.md.")
  }
}
