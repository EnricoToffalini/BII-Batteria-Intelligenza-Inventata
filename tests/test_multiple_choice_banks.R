# Controlli di qualita validi per ogni subtest a scelta multipla.
# Vivono qui e non nei test del singolo subtest: cosi un nuovo item bank a
# scelta multipla eredita i controlli senza che nessuno debba ricopiarli.

source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)
source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)

spec <- read_bii_spec(root)
option_columns <- c("option_a", "option_b", "option_c", "option_d")

mc_ids <- Filter(
  function(id) grepl("multiple_choice", spec$subtests[[id]]$response_format),
  subtests_with_item_bank(root, spec)
)
if (length(mc_ids) == 0L) stop("Nessun item bank a scelta multipla trovato.")

for (id in mc_ids) {
  context <- load_item_bank(id, root, spec)
  items <- context$items
  all_items <- rbind(context$practice, items)

  # La chiave testuale deve coincidere con l'opzione indicata da
  # correct_answer: e l'errore piu facile da introdurre spostando un'opzione.
  for (i in seq_len(nrow(all_items))) {
    letter <- all_items$correct_answer[i]
    if (!letter %in% LETTERS[1:4]) stop(all_items$item_id[i], ": correct_answer non valida.")
    chosen <- all_items[[option_columns[match(letter, LETTERS[1:4])]]][i]
    if (!identical(trimws(chosen), trimws(all_items$scoring_key[i]))) {
      stop(all_items$item_id[i], ": scoring_key diverso dall'opzione indicata da correct_answer.")
    }
    if (!grepl(letter, all_items$scoring_rubric[i], fixed = TRUE)) {
      stop(all_items$item_id[i], ": la rubrica non cita la lettera della risposta corretta.")
    }
  }

  # Le famiglie devono alternarsi: serie lunghe insegnerebbero la strategia
  # durante la prova invece di misurarla.
  families <- items$family[order(items$order)]
  if (length(families) > 1L && any(families[-1] == families[-length(families)])) {
    stop(id, ": stessa famiglia in posizioni adiacenti.")
  }

  # Nessuna consegna ripetuta con le stesse identiche opzioni.
  signature <- do.call(paste, c(list(all_items$prompt), all_items[option_columns]))
  if (anyDuplicated(signature)) stop(id, ": item duplicato (stessa consegna e stesse opzioni).")

  # Le risposte corrette non devono concentrarsi su una lettera.
  letter_counts <- table(factor(items$correct_answer, levels = LETTERS[1:4]))
  if (any(letter_counts < 3) || max(letter_counts) - min(letter_counts) > 4) {
    stop(id, ": risposte corrette sbilanciate fra le quattro lettere.")
  }

  # Ogni distrattore deve essere motivato.
  if (any(!nzchar(trimws(all_items$distractor_rationale)))) {
    stop(id, ": rationale dei distrattori mancante.")
  }

  # Un subtest che dichiara un vocabolario chiuso di simboli non deve
  # contenerne altri: un glifo estraneo cambierebbe lo spazio delle regole
  # possibili e potrebbe non essere disponibile in stampa.
  declared <- unlist(context$spec$symbol_vocabulary, use.names = FALSE)
  if (!is.null(declared)) {
    text <- paste(
      c(all_items$prompt, unlist(all_items[option_columns], use.names = FALSE),
        all_items$scoring_key, all_items$distractor_rationale),
      collapse = ""
    )
    chars <- unique(strsplit(text, "")[[1]])
    code_points <- vapply(chars, utf8ToInt, integer(1))
    # Sopra U+2000 stanno i simboli veri e propri; le lettere accentate
    # italiane restano molto sotto questa soglia.
    used <- chars[code_points >= 0x2000]
    extra <- setdiff(used, declared)
    if (length(extra)) {
      stop(
        id, ": simboli non dichiarati in symbol_vocabulary: ",
        paste(sprintf("U+%04X", vapply(extra, utf8ToInt, integer(1))), collapse = " "), "."
      )
    }
  }
}
