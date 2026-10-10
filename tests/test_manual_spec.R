# Il manuale ripete per l'esaminatore numeri che vivono nella spec: punti di
# partenza, range grezzi, filler, ordine di somministrazione e durate. Il test
# li confronta con la spec, perché una copia in prosa diverge in silenzio: è
# successo con il filler di CR, indicato come F15_A mentre la spec assegna F15_V.

source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)
spec <- read_bii_spec(root)
manual <- readLines(file.path(root, "manual", "ADMINISTRATION.md"), encoding = "UTF-8", warn = FALSE)

complete <- names(spec$subtests)[vapply(spec$subtests, function(st) {
  identical(st$item_bank$status, "complete_draft")
}, logical(1))]

manual_section <- function(id) {
  tops <- grep("^# ", manual)
  start <- grep(paste0("^# ", id, " — "), manual)
  if (length(start) != 1L) stop("Manuale: sezione di ", id, " assente o duplicata.")
  end <- c(tops[tops > start], length(manual) + 1L)[1] - 1L
  manual[start:end]
}

# Tabella markdown subito dopo un'intestazione: righe di dati, celle ripulite.
table_after <- function(lines, heading_pattern) {
  at <- grep(heading_pattern, lines)
  if (length(at) != 1L) stop("Manuale: intestazione non trovata: ", heading_pattern)
  rows <- character()
  for (line in lines[(at + 1L):length(lines)]) {
    if (grepl("^\\|", line)) rows <- c(rows, line) else if (length(rows)) break
  }
  rows <- rows[-(1:2)]
  lapply(strsplit(rows, "\\|"), function(cells) trimws(cells[nzchar(trimws(cells))]))
}

age_label <- function(months) {
  sprintf("%d;%d–%d;%d", months[1] %/% 12, months[1] %% 12, months[2] %/% 12, months[2] %% 12)
}

for (id in complete) {
  st <- spec$subtests[[id]]
  section <- manual_section(id)
  text <- paste(section, collapse = " ")

  range <- regmatches(text, regexpr("[Rr]ange grezzo( valido è)? 0–[0-9]+", text))
  if (length(range) != 1L || as.integer(sub(".*–", "", range)) != st$scoring$raw_max) {
    stop("Manuale ", id, ": range grezzo diverso da 0–", st$scoring$raw_max, " della spec.")
  }

  starts <- st$administration$start_points
  if (!is.null(starts)) {
    rows <- table_after(section, "^## (Punto|Livello) di partenza")
    if (length(rows) != length(starts)) stop("Manuale ", id, ": righe della tabella di partenza diverse dalla spec.")
    for (k in seq_along(starts)) {
      expected <- if (!is.null(starts[[k]]$item)) starts[[k]]$item else starts[[k]]$sequence_length
      got <- as.integer(sub("^([0-9]+).*$", "\\1", rows[[k]][2]))
      if (!identical(rows[[k]][1], age_label(unlist(starts[[k]]$age_months))) || !identical(got, as.integer(expected))) {
        stop("Manuale ", id, ": punto di partenza ", paste(rows[[k]], collapse = " | "), " diverso dalla spec.")
      }
    }
  }

  # Un filler citato in una sezione è quello assegnato al subtest, oppure è
  # nominato esplicitamente come riservato al suo subtest.
  for (filler in names(spec$battery$administration$fillers)) {
    if (!grepl(filler, text, fixed = TRUE)) next
    use_with <- spec$battery$administration$fillers[[filler]]$use_with
    if (use_with != id && !grepl(paste0("`", filler, "`[^.]*riservato a ", use_with), text)) {
      stop("Manuale ", id, ": cita ", filler, ", che la spec assegna a ", use_with, ".")
    }
  }
  for (filler in names(spec$battery$administration$fillers)) {
    if (spec$battery$administration$fillers[[filler]]$use_with == id && !grepl(filler, text, fixed = TRUE)) {
      stop("Manuale ", id, ": non cita il filler ", filler, " previsto dalla spec.")
    }
  }
}

# --- ordine di somministrazione --------------------------------------------------

sequence_label <- function(step) {
  labels <- c(CR_study = "CR studio", CR_delayed_retrieval = "CR recupero",
              DM_study = "DM studio", DM_delayed_retrieval = "DM recupero")
  if (step %in% names(labels)) return(labels[[step]])
  if (grepl("_if_needed$", step)) return(paste(sub("_if_needed$", "", step), "se serve"))
  step
}
step_subtest <- function(step) sub("_(study|delayed_retrieval|if_needed)$", "", step)

sequences <- spec$battery$administration$sequences
sequence_rows <- table_after(manual, "^## Ordine di somministrazione")
sequence_names <- c(QI_rapido = "QI rapido", QI_totale = "QI totale",
                    complete_indices_after_QI_totale = "Indici completi, dopo il QI totale")
if (!setequal(names(sequences), names(sequence_names))) {
  stop("Manuale: la spec ha sequenze non descritte nella tabella dell'ordine di somministrazione.")
}
for (name in names(sequences)) {
  row <- sequence_rows[[match(sequence_names[[name]], vapply(sequence_rows, `[`, "", 1))]]
  steps <- unlist(sequences[[name]], use.names = FALSE)
  planned <- paste(vapply(steps, sequence_label, ""), collapse = ", ")
  available <- paste(vapply(steps[step_subtest(steps) %in% complete], sequence_label, ""), collapse = ", ")
  if (!identical(row[2], planned)) stop("Manuale: ordine di ", name, " diverso dalla spec: ", row[2])
  if (!identical(row[3], available)) stop("Manuale: subtest disponibili di ", name, " diversi dalla spec: ", row[3])
}

# --- durate previste ------------------------------------------------------------

span <- function(x) {
  x <- unlist(x)
  if (length(x) == 1L || x[1] == x[2]) as.character(x[1]) else paste0(x[1], "–", x[2])
}
duration_rows <- table_after(manual, "^Durate previste dalla spec")
duration_ids <- vapply(duration_rows, `[`, "", 1)
if (!setequal(duration_ids, complete)) stop("Manuale: la tabella delle durate non copre i subtest completi.")
for (row in duration_rows) {
  timing <- spec$subtests[[row[1]]]$timing
  expected <- if (!is.null(timing$planned_minutes)) span(timing$planned_minutes) else paste0(
    "studio ", span(timing$study_minutes), ", intervallo ", timing$retention_minutes,
    ", recupero ", span(timing$retrieval_minutes)
  )
  if (!identical(row[2], expected)) stop("Manuale: durata di ", row[1], " diversa dalla spec: ", row[2])
}
