# La specifica narrativa legacy non deve contraddire spec/.
#
# `_BII - Batteria Intelligenza Inventata.md` e documentazione sincronizzata,
# non una seconda fonte di verita (vedi AGENTS.md e decision record 0001). In
# pratica pero e prosa lunga che nessuno rilegge quando cambia un valore nella
# spec, e i due possono divergere senza che niente lo segnali: e successo con
# SM e CR, i cui `raw_max` sono cambiati costruendo gli item bank, mentre il
# documento narrativo continuava a dichiarare i valori vecchi.
#
# Questo test confronta l'unico dato che il documento riporta in forma
# strutturata e confrontabile: il range del punteggio grezzo dichiarato nei
# blocchi "Parametri di somministrazione". Non pretende di validare la prosa.

source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)

spec <- read_bii_spec(root)
legacy_path <- file.path(root, "_BII - Batteria Intelligenza Inventata.md")
lines <- readLines(legacy_path, encoding = "UTF-8", warn = FALSE)

# L'ID del subtest compare fra parentesi quadre nell'intestazione di sezione,
# per esempio "## 4.1 Sequenze e Manipolazione [SM] (core, ...)".
id_from_heading <- function(heading) {
  open_at <- regexpr("[", heading, fixed = TRUE)
  close_at <- regexpr("]", heading, fixed = TRUE)
  if (open_at < 0 || close_at <= open_at + 1) return(NA_character_)
  substr(heading, open_at + 1, close_at - 1)
}

range_lines <- grep("Range punteggio grezzo", lines)
if (length(range_lines) == 0L) {
  stop("Nessun 'Range punteggio grezzo' trovato nella specifica narrativa legacy.")
}

checked <- character()
for (position in range_lines) {
  headings <- grep("^##[^#]", lines[seq_len(position)], value = TRUE)
  if (length(headings) == 0L) next
  id <- id_from_heading(rev(headings)[1])
  if (is.na(id) || !id %in% names(spec$subtests)) next

  # I subtest a punteggio derivato da componenti (CL, SS, DM) non dichiarano un
  # range numerico in quel punto: non c'e niente da confrontare.
  numbers <- regmatches(lines[position], gregexpr("[0-9]+", lines[position]))[[1]]
  if (length(numbers) < 2L) next

  legacy_max <- as.integer(numbers[2])
  declared_max <- as.integer(spec$subtests[[id]]$scoring$raw_max)
  if (!identical(legacy_max, declared_max)) {
    stop(
      id, ": la specifica narrativa legacy dichiara un range grezzo 0-", legacy_max,
      " ma spec/subtests/", id, ".yml dichiara 0-", declared_max,
      ". La spec e la fonte di verita: aggiornare il documento narrativo."
    )
  }
  checked <- c(checked, id)
}

if (length(checked) < 10L) {
  stop(
    "Confrontati solo ", length(checked),
    " subtest con la specifica narrativa: il formato del documento e cambiato ",
    "e il controllo non sta piu verificando quello che dovrebbe."
  )
}

message("[legacy] range grezzi confrontati con la spec: ", paste(sort(checked), collapse = ", "))
