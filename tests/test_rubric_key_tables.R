# Le tabelle chiave delle rubriche devono coincidere con l'item bank.
#
# Perche questo test esiste: le rubriche contengono tabelle scritte a mano che
# ripetono la chiave gia presente nel CSV. E' documentazione utile
# all'esaminatore, ma duplica la fonte di verita, e una tabella che diverge dal
# CSV fa somministrare un item e correggerne un altro. E' successo tre volte
# durante lo sviluppo di CR, PG e SM, ogni volta scoperto per caso.
#
# Regola verificata: **se la rubrica di un subtest contiene una tabella che
# nomina almeno un item scored, allora deve nominarli tutti, e ogni riga deve
# riportare il materiale-chiave di quell'item come sta nel CSV.**
#
# I subtest con rubrica in prosa invece che in tabella (SP, CS, QS: una sezione
# per item, senza tabella riassuntiva) non sono coperti da questo controllo, e
# il test lo dice esplicitamente invece di far finta di verificarli.
#
# Gli item di prova sono esclusi: le loro tabelle usano formattazioni
# discorsive (per esempio "D1 → A1" invece di "D1 A1") che non si prestano al
# confronto letterale, e non determinano il punteggio.

source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)
source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)

spec <- read_bii_spec(root)
banked <- subtests_with_item_bank(root, spec)

# Colonne il cui valore, se presente nell'item bank, deve comparire nella riga
# di tabella. Sono tutte brevi e letterali: chiave, sequenza, bersaglio, cue.
BII_KEY_COLUMNS_LITERAL <- c("cue", "sequence", "target")

covered <- character()
skipped <- character()

for (id in banked) {
  context <- load_item_bank(id, root, spec)
  items <- context$items

  rubric_files <- unique(sub("#.*$", "", c(items$rubric_ref, context$practice$rubric_ref)))
  rubric_files <- rubric_files[nzchar(rubric_files)]
  lines <- unlist(lapply(
    file.path(root, rubric_files),
    function(path) readLines(path, encoding = "UTF-8", warn = FALSE)
  ))
  table_rows <- grep("^[[:space:]]*\\|", lines, value = TRUE)

  mentioned <- vapply(
    items$item_id,
    function(item_id) any(grepl(item_id, table_rows, fixed = TRUE)),
    logical(1)
  )
  if (!any(mentioned)) {
    # Rubrica in prosa: nessuna tabella chiave da verificare.
    skipped <- c(skipped, id)
    next
  }
  covered <- c(covered, id)

  # Se la rubrica tiene una tabella chiave, deve essere completa.
  if (!all(mentioned)) {
    missing <- items$item_id[!mentioned]
    stop(
      id, ": la tabella chiave della rubrica non nomina ",
      length(missing), " item scored (per esempio ", missing[1],
      "). Una tabella chiave incompleta e peggio di nessuna tabella."
    )
  }

  literal_columns <- intersect(BII_KEY_COLUMNS_LITERAL, names(items))
  has_letter_key <- "correct_answer" %in% names(items)

  for (i in seq_len(nrow(items))) {
    item_id <- items$item_id[i]
    rows <- table_rows[grepl(item_id, table_rows, fixed = TRUE)]

    # Basta che UNA riga sia corretta: lo stesso item puo comparire in piu
    # tabelle (per esempio un riepilogo oltre alla chiave del microblocco).
    row_ok <- vapply(rows, function(row) {
      for (column in literal_columns) {
        value <- trimws(as.character(items[[column]][i]))
        if (!nzchar(value)) next
        if (!grepl(value, row, fixed = TRUE)) return(FALSE)
      }
      if (has_letter_key) {
        letter <- trimws(as.character(items$correct_answer[i]))
        if (nzchar(letter) && !grepl(paste0("\\b", letter, "\\b"), row)) return(FALSE)
      }
      TRUE
    }, logical(1))

    if (!any(row_ok)) {
      details <- paste(
        c(
          if (length(literal_columns)) {
            paste0(literal_columns, " = \"", vapply(literal_columns, function(cc) as.character(items[[cc]][i]), character(1)), "\"")
          },
          if (has_letter_key) paste0("correct_answer = ", items$correct_answer[i])
        ),
        collapse = "; "
      )
      stop(
        id, ": la riga di tabella per ", item_id,
        " non riporta il materiale-chiave dell'item bank (", details,
        "). Rigenerare la tabella dal CSV invece di correggerla a mano."
      )
    }
  }
}

if (length(covered) == 0L) stop("Nessuna rubrica con tabella chiave da verificare.")

message(
  "[rubriche] tabelle chiave verificate: ", paste(sort(covered), collapse = ", "),
  if (length(skipped)) paste0(" | rubriche in prosa, non coperte: ", paste(sort(skipped), collapse = ", ")) else ""
)
