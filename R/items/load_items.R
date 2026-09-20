# Caricamento dell'item bank BII.
#
# Un solo punto di accesso ai CSV in items/source/ per tutto il resto del
# codice: scoring, simulazione, test e materiali devono leggere gli item da
# qui, non riaprendo i file per conto proprio.

bii_find_root <- function(start = getwd()) {
  path <- normalizePath(start, winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(path, "spec", "battery.yml"))) return(path)
    parent <- dirname(path)
    if (identical(parent, path)) break
    path <- parent
  }
  stop("Impossibile trovare la cartella principale della BII.", call. = FALSE)
}

bii_spec <- function(root = NULL) {
  if (is.null(root)) root <- bii_find_root()
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  if (exists("read_bii_spec", mode = "function", inherits = TRUE)) {
    reader <- get("read_bii_spec", mode = "function", inherits = TRUE)
  } else {
    loader <- new.env(parent = baseenv())
    sys.source(file.path(root, "R", "spec", "load_spec.R"), envir = loader)
    reader <- loader$read_bii_spec
  }
  reader(root)
}

# Restituisce spec del subtest, item scored in ordine di somministrazione e
# item di prova. `items` contiene sempre e soltanto gli item scored: è la
# sequenza su cui operano routing e scoring.
load_item_bank <- function(subtest_id, root = NULL, spec = NULL) {
  if (is.null(root)) root <- bii_find_root()
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  if (is.null(spec)) spec <- bii_spec(root)
  st <- spec$subtests[[subtest_id]]
  if (is.null(st)) stop("Subtest sconosciuto nella spec: ", subtest_id, ".", call. = FALSE)
  if (is.null(st$item_bank)) {
    stop("Il subtest ", subtest_id, " non ha ancora un item bank dichiarato nella spec.", call. = FALSE)
  }
  path <- file.path(root, st$item_bank$path)
  if (!file.exists(path)) stop("Item bank non trovato: ", st$item_bank$path, ".", call. = FALSE)
  all_items <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
  all_items <- all_items[all_items$subtest == subtest_id, , drop = FALSE]
  scored <- all_items[all_items$item_type == "scored", , drop = FALSE]
  scored <- scored[order(scored$order), , drop = FALSE]
  practice <- all_items[all_items$item_type == "practice", , drop = FALSE]
  practice <- practice[order(practice$order), , drop = FALSE]
  if (nrow(scored) == 0L) stop(subtest_id, ": nessun item scored nell'item bank.", call. = FALSE)
  if (!identical(scored$order, seq_len(nrow(scored)))) {
    stop(subtest_id, ": l'ordine degli item scored non e' continuo da 1.", call. = FALSE)
  }
  list(
    subtest = subtest_id,
    spec = st,
    battery = spec$battery,
    root = root,
    items = scored,
    practice = practice
  )
}

# Elenco dei subtest che hanno gia' un item bank collegato nella spec.
subtests_with_item_bank <- function(root = NULL, spec = NULL) {
  if (is.null(spec)) spec <- bii_spec(root)
  ids <- spec$battery$subtest_order
  ids[vapply(spec$subtests[ids], function(x) !is.null(x$item_bank), logical(1))]
}
