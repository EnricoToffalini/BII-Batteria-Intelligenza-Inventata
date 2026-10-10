# Le parole che SP chiede di definire non devono comparire negli stimoli di
# altri subtest. Se compaiono, la conoscenza di una stessa parola entra in due
# punteggi (dipendenza locale): SP e RS formano insieme qIC, e una parola
# condivisa gonfierebbe la loro correlazione. Il controllo riguarda solo gli
# stimoli presentati (consegna, opzioni, cue, bersaglio), non chiavi o rubriche.

source(file.path(root, "R", "items", "load_items.R"), local = TRUE)
spec <- bii_spec(root)

sp <- load_item_bank("SP", root, spec)$items
targets <- tolower(sub("^Che cosa significa ([[:alpha:]]+)[?]$", "\\1", sp$prompt))
if (any(targets == tolower(sp$prompt))) stop("SP: consegna in un formato non riconosciuto dal test.")

stimulus_columns <- c("prompt", "option_a", "option_b", "option_c", "option_d", "cue", "target")
for (id in setdiff(subtests_with_item_bank(root, spec), "SP")) {
  context <- load_item_bank(id, root, spec)
  items <- rbind(context$practice[intersect(names(context$practice), c("item_id", stimulus_columns))],
                 context$items[intersect(names(context$items), c("item_id", stimulus_columns))])
  for (i in seq_len(nrow(items))) {
    text <- tolower(paste(unlist(items[i, setdiff(names(items), "item_id")]), collapse = " "))
    words <- strsplit(text, "[^[:alpha:]]+")[[1]]
    shared <- intersect(targets, words)
    if (length(shared)) {
      stop(items$item_id[i], " usa negli stimoli la parola di SP «", shared[1], "».")
    }
  }
}
