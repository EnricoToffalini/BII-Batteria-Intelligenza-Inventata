# Struttura minima delle rubriche 0/1/2 aperte. Il test non prova a decidere
# la qualità semantica degli esempi, ma impedisce che un item perda in silenzio
# uno dei tre livelli o il rinvio alla sua sezione dettagliata.

source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)
spec <- read_bii_spec(root)

# Stesso criterio di moduli di registrazione e accordo fra correttori.
source(file.path(root, "R", "items", "load_items.R"), local = TRUE)
open_ids <- open_response_subtests(spec)

if (length(open_ids) == 0L) stop("Nessuna rubrica aperta 0/1/2 da verificare.")

# Le rubriche aperte ammettono una query: il modulo deve poterla registrare.
for (id in open_ids) {
  form <- utils::read.csv(file.path(root, "materials", "record_forms", paste0(id, "_record_form.csv")), check.names = FALSE)
  if (!"query_used" %in% names(form)) stop(id, ": il modulo di registrazione non ha la colonna query_used.")
}

# Esempi fra «» per livello in una sezione di item; un punto elenco continua
# sulle righe indentate che lo seguono.
open_rubric_examples <- function(section) {
  starts <- grep("^- [012] punt[oi]:", section)
  out <- data.frame(score = integer(0), text = character(0))
  for (k in seq_along(starts)) {
    to <- starts[k]
    while (to < length(section) && grepl("^  \\S", section[to + 1L])) to <- to + 1L
    bullet <- gsub("\\s+", " ", paste(section[starts[k]:to], collapse = " "))
    quoted <- regmatches(bullet, gregexpr("«[^»]+»", bullet))[[1]]
    if (length(quoted) == 0L) next
    out <- rbind(out, data.frame(
      score = as.integer(substr(bullet, 3, 3)),
      text = tolower(gsub("^«|»$", "", quoted))
    ))
  }
  unique(out)
}

level_text <- function(path, item_id, score) {
  rubric <- readLines(path, warn = FALSE, encoding = "UTF-8")
  start <- match(paste("##", item_id), rubric)
  end <- c(grep("^## ", rubric), length(rubric) + 1L)
  end <- min(end[end > start]) - 1L
  ex <- open_rubric_examples(rubric[(start + 1L):end])
  ex$text[ex$score == score]
}

for (id in open_ids) {
  items <- utils::read.csv(
    file.path(root, spec$subtests[[id]]$item_bank$path),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  rubric_paths <- unique(sub("#.*$", "", items$rubric_ref))
  if (length(rubric_paths) != 1L) {
    stop(id, ": gli item aperti devono rinviare a una sola rubrica di subtest.")
  }

  rubric <- readLines(file.path(root, rubric_paths), warn = FALSE, encoding = "UTF-8")
  headings <- tolower(trimws(rubric[grepl("^## ", rubric)]))

  # AGENTS.md: il significato dei livelli è dichiarato una volta, in testa,
  # prima di qualunque sezione di item.
  criterion <- match("## come si assegna il punteggio", headings)
  first_item <- min(match(paste("##", tolower(items$item_id)), headings))
  if (is.na(criterion) || criterion > first_item) {
    stop(id, ": manca la sezione «Come si assegna il punteggio» prima degli item.")
  }
  heading_rows <- which(grepl("^## ", rubric))
  criterion_text <- rubric[(heading_rows[criterion] + 1L):(heading_rows[criterion + 1L] - 1L)]
  for (score in 2:0) {
    point_label <- if (score == 1L) "punto" else "punti"
    if (!any(grepl(paste0("^- \\*\\*", score, " ", point_label, "\\*\\*"), criterion_text))) {
      stop(id, ": il criterio generale non definisce il livello ", score, ".")
    }
  }

  for (item_id in tolower(items$item_id)) {
    heading <- paste("##", item_id)
    start <- match(heading, headings)
    if (is.na(start)) stop(id, ": sezione mancante per ", toupper(item_id), ".")

    heading_rows <- which(grepl("^## ", rubric))
    from <- heading_rows[start] + 1L
    to <- if (start < length(heading_rows)) heading_rows[start + 1L] - 1L else length(rubric)
    section <- rubric[from:to]
    for (score in 2:0) {
      point_label <- if (score == 1L) "punto" else "punti"
      if (!any(grepl(paste0("^- ", score, " ", point_label, ":"), section))) {
        stop(id, ": ", toupper(item_id), " non documenta il livello ", score, ".")
      }
    }

    # Un esempio citato fra «» non può stare a due livelli dello stesso item.
    # Le risposte il cui punteggio dipende dalla query si descrivono senza «».
    examples <- open_rubric_examples(section)
    clash <- unique(examples$text[duplicated(examples$text)])
    clash <- clash[vapply(clash, function(t) {
      length(unique(examples$score[examples$text == t])) > 1L
    }, logical(1))]
    if (length(clash) > 0L) {
      stop(id, ": ", toupper(item_id), " cita «", clash[1], "» a due livelli.")
    }
  }
}

# Regressione dell'audit N3: per gli item CS in cui una strategia poteva
# ricevere 2 punti senza spiegazione, la chiave strutturata deve ora distinguere
# esplicitamente il nesso/meccanismo dalla sola azione utile.
cs <- utils::read.csv(file.path(root, "items", "source", "CS.csv"), stringsAsFactors = FALSE)
audited <- cs$item_id %in% c("CS-SC-01", "CS-SC-03", "CS-SC-04", "CS-SC-05", "CS-SC-09")
full_credit <- sub(";.*$", "", cs$scoring_rubric[audited])
if (any(!grepl("nesso|colleg|spiega|spiegazione", full_credit, ignore.case = TRUE))) {
  stop("CS: un item auditato assegna ancora 2 punti senza richiedere il meccanismo.")
}

# Regressione dell'audit N3-SP: sinonimi adeguati valgono 2, non 1. «Sottinteso»
# e «passeggero» erano assegnati a 1 punto pur essendo sinonimi di *implicito*
# ed *effimero*; «programmare» era a 0 pur conservando l'idea di anticipo.
sp_rubric <- file.path(root, "items", "rubrics", "SP.md")
if (!"sottinteso" %in% level_text(sp_rubric, "SP-SC-13", 2L) ||
    !"passeggero" %in% level_text(sp_rubric, "SP-SC-17", 2L)) {
  stop("SP: un sinonimo adeguato non è più assegnato a 2 punti.")
}
if (!"programmare" %in% level_text(sp_rubric, "SP-SC-07", 1L)) {
  stop("SP: «programmare» per prevedere non è più un passo corretto da 1 punto.")
}

# Regressione dell'audit N3-QS: il punto parziale marca un passaggio di un
# percorso valido, non la sola direzione giusta ottenuta con un altro metodo.
qs_rubric <- file.path(root, "items", "rubrics", "QS.md")
if (!"6 giorni" %in% level_text(qs_rubric, "QS-SC-09", 0L)) {
  stop("QS: il metodo additivo in QS-SC-09 non è più esplicitamente a 0 punti.")
}
if (!"la prima va il doppio della seconda" %in% level_text(qs_rubric, "QS-SC-11", 1L)) {
  stop("QS: il punto parziale di QS-SC-11 non richiede più un passaggio corretto.")
}
qs <- utils::read.csv(file.path(root, "items", "source", "QS.csv"), stringsAsFactors = FALSE)
partial <- sub("^.*; 1 = ([^;]*);.*$", "\\1",qs$scoring_rubric[qs$item_id %in% c("QS-SC-09", "QS-SC-11")])
if (any(!grepl("passaggio", partial))) {
  stop("QS: la chiave strutturata assegna 1 punto alla sola direzione giusta.")
}
