#!/usr/bin/env Rscript

# Genera il prototipo ridotto e non definitivo di SS.
#
#   Rscript R/build/build_ss_prototype.R
#
# Le celle vivono in items/prototypes/SS/. Lo script non crea la forma scored
# da 200 stimoli e non modifica timing o scoring.

bii_ss_root <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) == 1L) {
    script <- normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE))
  }
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

ss_symbol_primitives <- function() {
  c(
    circle_vertical = paste0(
      '<circle cx="0" cy="0" r="2.55" fill="none" stroke="black" stroke-width="0.38"/>',
      '<path d="M 0 -1.55 V 1.55" fill="none" stroke="black" stroke-width="0.38" stroke-linecap="round"/>'
    ),
    circle_horizontal = paste0(
      '<circle cx="0" cy="0" r="2.55" fill="none" stroke="black" stroke-width="0.38"/>',
      '<path d="M -1.55 0 H 1.55" fill="none" stroke="black" stroke-width="0.38" stroke-linecap="round"/>'
    ),
    square_vertical = paste0(
      '<rect x="-2.55" y="-2.55" width="5.10" height="5.10" fill="none" stroke="black" stroke-width="0.38"/>',
      '<path d="M 0 -1.55 V 1.55" fill="none" stroke="black" stroke-width="0.38" stroke-linecap="round"/>'
    ),
    square_horizontal = paste0(
      '<rect x="-2.55" y="-2.55" width="5.10" height="5.10" fill="none" stroke="black" stroke-width="0.38"/>',
      '<path d="M -1.55 0 H 1.55" fill="none" stroke="black" stroke-width="0.38" stroke-linecap="round"/>'
    ),
    triangle_vertical = paste0(
      '<polygon points="0,-2.75 2.65,2.20 -2.65,2.20" fill="none" stroke="black" stroke-width="0.38" stroke-linejoin="round"/>',
      '<path d="M 0 -1.25 V 1.35" fill="none" stroke="black" stroke-width="0.38" stroke-linecap="round"/>'
    ),
    triangle_horizontal = paste0(
      '<polygon points="0,-2.75 2.65,2.20 -2.65,2.20" fill="none" stroke="black" stroke-width="0.38" stroke-linejoin="round"/>',
      '<path d="M -1.45 0.45 H 1.45" fill="none" stroke="black" stroke-width="0.38" stroke-linecap="round"/>'
    )
  )
}

ss_symbol <- function(x, y, token, primitives = ss_symbol_primitives(), stimulus_id = NULL) {
  if (length(token) != 1L || is.na(primitives[token])) {
    stop("Token SS privo di primitiva SVG: ", token, call. = FALSE)
  }
  id_attr <- if (is.null(stimulus_id)) "" else sprintf(' data-stimulus-id="%s"', stimulus_id)
  sprintf('<g%s transform="translate(%.3f %.3f)">%s</g>', id_attr, x, y, unname(primitives[token]))
}

ss_max_run <- function(x) max(rle(x)$lengths)

ss_max_alternating_run <- function(x) {
  changes <- x[-1L] != x[-length(x)]
  runs <- rle(changes)
  if (!any(runs$values)) return(1L)
  max(runs$lengths[runs$values]) + 1L
}

validate_ss_prototype <- function(root) {
  if (!exists("read_bii_spec", mode = "function")) {
    source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)
  }
  spec <- read_bii_spec(root)$subtests$SS
  source_path <- file.path(root, "items", "prototypes", "SS", "stimulus_cells.csv")
  key_path <- file.path(root, "items", "prototypes", "SS", "stimulus_keys.csv")
  cells <- utils::read.csv(source_path, stringsAsFactors = FALSE, check.names = FALSE)
  keys <- utils::read.csv(key_path, stringsAsFactors = FALSE, check.names = FALSE)

  expected_cells <- c("stimulus_id", "section", "row", "column", "token", "status")
  expected_keys <- c("stimulus_id", "is_target")
  if (!identical(names(cells), expected_cells)) stop("Colonne della sorgente SS non valide.", call. = FALSE)
  if (!identical(names(keys), expected_keys)) stop("Colonne della chiave SS non valide.", call. = FALSE)
  if (nrow(cells) != 72L || nrow(keys) != 72L) stop("P5P richiede 12 celle di pratica e 60 di prototipo.", call. = FALSE)
  if (anyDuplicated(cells$stimulus_id) || anyDuplicated(keys$stimulus_id)) stop("ID SS duplicato.", call. = FALSE)
  if (!setequal(cells$stimulus_id, keys$stimulus_id)) stop("Sorgente e chiave SS hanno ID diversi.", call. = FALSE)
  keys <- keys[match(cells$stimulus_id, keys$stimulus_id), , drop = FALSE]
  if (any(is.na(keys$is_target))) stop("Chiave SS incompleta.", call. = FALSE)

  vocabulary <- unlist(spec$symbol_vocabulary, use.names = FALSE)
  primitives <- ss_symbol_primitives()
  if (!setequal(names(primitives), vocabulary)) stop("Vocabolario SS e primitive SVG non corrispondono.", call. = FALSE)
  if (anyDuplicated(unname(primitives))) stop("Ogni token SS deve avere una primitiva distinta.", call. = FALSE)
  if (!all(cells$token %in% vocabulary)) stop("La sorgente SS usa token fuori vocabolario.", call. = FALSE)
  if (any(cells$status != "non_definitive")) stop("Tutte le celle P5P devono restare non definitive.", call. = FALSE)
  expected_target <- cells$token == spec$stimulus_composition$target_token
  if (!identical(keys$is_target, expected_target)) stop("La chiave SS non coincide con il target dichiarato nella spec.", call. = FALSE)

  practice <- cells$section == "practice"
  prototype <- cells$section == "prototype"
  if (sum(practice) != 12L || sum(prototype) != 60L || any(!(practice | prototype))) {
    stop("Sezioni SS non valide.", call. = FALSE)
  }
  if (sum(keys$is_target[practice]) != 6L || sum(!keys$is_target[practice]) != 6L) {
    stop("La pratica SS deve contenere 6 target e 6 distrattori.", call. = FALSE)
  }
  practice_distractors <- unique(cells$token[practice & !keys$is_target])
  if (!setequal(practice_distractors, setdiff(vocabulary, spec$stimulus_composition$target_token))) {
    stop("La pratica SS deve mostrare tutti i distrattori.", call. = FALSE)
  }
  if (sum(keys$is_target[prototype]) != 30L || sum(!keys$is_target[prototype]) != 30L) {
    stop("Il prototipo SS deve contenere 30 target e 30 distrattori.", call. = FALSE)
  }

  proto <- cells[prototype, , drop = FALSE]
  proto_key <- keys$is_target[prototype]
  if (!identical(sort(unique(proto$row)), 1:6) || !identical(sort(unique(proto$column)), 1:10)) {
    stop("Il prototipo SS deve essere una matrice 6 x 10 completa.", call. = FALSE)
  }
  if (any(table(proto$row) != 10L) || any(table(proto$column) != 6L)) stop("Reticolo SS incompleto.", call. = FALSE)
  targets_by_row <- as.integer(tapply(proto_key, proto$row, sum))
  if (!identical(targets_by_row, c(4L, 6L, 5L, 4L, 6L, 5L))) stop("Conteggi target per riga SS non validi.", call. = FALSE)
  distractor_counts <- table(proto$token[!proto_key])
  expected_distractors <- unlist(spec$stimulus_composition$distractor_counts, use.names = TRUE)
  if (!identical(as.integer(distractor_counts[names(expected_distractors)]), rep(6L, 5L))) {
    stop("Ogni distrattore SS deve comparire sei volte nel prototipo.", call. = FALSE)
  }

  target_matrix <- matrix(FALSE, nrow = 6L, ncol = 10L)
  token_matrix <- matrix("", nrow = 6L, ncol = 10L)
  for (i in 1:6) {
    idx <- proto$row == i
    row_tokens <- proto$token[idx][order(proto$column[idx])]
    row_targets <- row_tokens == spec$stimulus_composition$target_token
    target_matrix[i, ] <- row_targets
    token_matrix[i, ] <- row_tokens
    if (ss_max_run(row_targets) > 2L) stop("Più di due celle dello stesso tipo consecutive nella riga ", i, ".", call. = FALSE)
    if (ss_max_alternating_run(row_targets) > 5L) stop("Alternanza target/distrattore troppo lunga nella riga ", i, ".", call. = FALSE)
    adjacent_equal_distractors <- !row_targets[-1L] & !row_targets[-length(row_targets)] &
      row_tokens[-1L] == row_tokens[-length(row_tokens)]
    if (any(adjacent_equal_distractors)) stop("Distrattori identici adiacenti nella riga ", i, ".", call. = FALSE)
  }

  targets_by_column <- colSums(target_matrix)
  if (any(targets_by_column < 2L | targets_by_column > 4L)) {
    stop("Ogni colonna SS deve contenere da due a quattro target nel prototipo.", call. = FALSE)
  }
  row_signatures <- apply(target_matrix, 1, paste0, collapse = "")
  complement_signatures <- apply(!target_matrix, 1, paste0, collapse = "")
  if (anyDuplicated(row_signatures)) stop("Due righe SS hanno le stesse posizioni target.", call. = FALSE)
  if (any(row_signatures %in% complement_signatures)) stop("Due righe SS sono inversioni target/distrattore.", call. = FALSE)

  for (column in 1:10) {
    column_targets <- target_matrix[, column]
    column_tokens <- token_matrix[, column]
    adjacent_equal_distractors <- !column_targets[-1L] & !column_targets[-length(column_targets)] &
      column_tokens[-1L] == column_tokens[-length(column_tokens)]
    if (any(adjacent_equal_distractors)) stop("Distrattori identici adiacenti nella colonna ", column, ".", call. = FALSE)
  }

  list(
    spec = spec, cells = cells, keys = keys, practice = practice,
    prototype = prototype, target_matrix = target_matrix,
    token_matrix = token_matrix
  )
}

ss_layout_svg <- function(context) {
  cells <- context$cells
  practice <- cells[context$practice, , drop = FALSE]
  prototype <- cells[context$prototype, , drop = FALSE]
  parts <- c(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<svg xmlns="http://www.w3.org/2000/svg" width="210mm" height="297mm" viewBox="0 0 210 297">',
    '<rect width="210" height="297" fill="white"/>',
    '<g font-family="Arial, Helvetica, sans-serif" fill="black">',
    '<text x="18" y="17" font-size="5.2" font-weight="bold">SS - Scansione Selettiva</text>',
    '<text x="18" y="24" font-size="3.0">PROTOTIPO RIDOTTO NON DEFINITIVO - materiale didattico, non clinico</text>',
    '<text x="18" y="35" font-size="3.4" font-weight="bold">Barra ogni cerchio con una linea verticale:</text>',
    ss_symbol(92, 33.8, context$spec$stimulus_composition$target_token),
    '<text x="18" y="47" font-size="3.0">Procedi da sinistra a destra; alla riga successiva torna al margine sinistro.</text>',
    '<text x="18" y="58" font-size="3.5" font-weight="bold">Pratica guidata</text>'
  )

  practice_x <- 57
  practice_y <- 66
  for (i in seq_len(nrow(practice))) {
    x <- practice_x + (practice$column[i] - 1) * 16
    y <- practice_y + (practice$row[i] - 1) * 10.5
    parts <- c(parts, ss_symbol(x, y, practice$token[i], stimulus_id = practice$stimulus_id[i]))
  }
  parts <- c(
    parts,
    '<text x="18" y="88" font-size="2.8">Correggere la pratica prima di iniziare. Il target resta visibile.</text>',
    '<line x1="18" y1="94" x2="192" y2="94" stroke="#777" stroke-width="0.25"/>',
    '<text x="18" y="103" font-size="3.5" font-weight="bold">Matrice prototipo - 6 righe su 20</text>'
  )

  matrix_x <- 31
  matrix_y <- 108
  pitch_x <- 16
  pitch_y <- 10.5
  for (row in 0:6) {
    y <- matrix_y + row * pitch_y
    parts <- c(parts, sprintf('<line x1="%.1f" y1="%.2f" x2="%.1f" y2="%.2f" stroke="#d6d6d6" stroke-width="0.20"/>', matrix_x, y, matrix_x + 160, y))
  }
  for (row in 1:6) {
    y <- matrix_y + (row - 0.5) * pitch_y + 1.0
    parts <- c(parts, sprintf('<text x="24" y="%.2f" font-size="2.7" text-anchor="end">%d</text>', y, row))
  }
  for (i in seq_len(nrow(prototype))) {
    x <- matrix_x + (prototype$column[i] - 0.5) * pitch_x
    y <- matrix_y + (prototype$row[i] - 0.5) * pitch_y
    parts <- c(parts, ss_symbol(x, y, prototype$token[i], stimulus_id = prototype$stimulus_id[i]))
  }

  parts <- c(
    parts,
    '<text x="31" y="181" font-size="2.8" fill="#555">Le 14 righe restanti non sono state generate in P5RR.</text>',
    '<text x="18" y="266" font-size="2.7">Stampare al 100%. Verificare la barra prima di valutare dimensioni e marcabilita.</text>',
    '<line x1="18" y1="276" x2="68" y2="276" stroke="black" stroke-width="0.55"/>',
    '<line x1="18" y1="273.5" x2="18" y2="278.5" stroke="black" stroke-width="0.55"/>',
    '<line x1="68" y1="273.5" x2="68" y2="278.5" stroke="black" stroke-width="0.55"/>',
    '<text x="43" y="283" font-size="2.8" text-anchor="middle">50 mm</text>',
    '<text x="192" y="283" font-size="2.6" text-anchor="end">SS-P5RR - A4 verticale</text>',
    '</g>',
    '</svg>'
  )
  paste(parts, collapse = "\n")
}

build_ss_prototype <- function(root, output_dir = file.path(root, "materials", "stimulus_books", "prototypes", "SS"), dpi = 300) {
  if (!requireNamespace("rsvg", quietly = TRUE)) stop("Il pacchetto R 'rsvg' è richiesto per renderizzare il prototipo SS.", call. = FALSE)
  if (!requireNamespace("magick", quietly = TRUE)) stop("Il pacchetto R 'magick' è richiesto per registrare la densità del prototipo SS.", call. = FALSE)
  context <- validate_ss_prototype(root)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  stem <- file.path(output_dir, "SS_search_prototype_A4_portrait")
  svg_path <- paste0(stem, ".svg")
  pdf_path <- paste0(stem, ".pdf")
  png_path <- paste0(stem, "_300dpi.png")
  writeBin(charToRaw(enc2utf8(ss_layout_svg(context))), svg_path)
  rsvg::rsvg_pdf(svg_path, pdf_path)
  pixels <- round(c(210, 297) / 25.4 * dpi)
  rsvg::rsvg_png(svg_path, png_path, width = pixels[1], height = pixels[2])
  magick::image_write(magick::image_read(png_path), png_path, density = paste0(dpi, "x", dpi))
  c(svg_path, pdf_path, png_path)
}

if (sys.nframe() == 0L) {
  root <- bii_ss_root()
  for (path in build_ss_prototype(root)) message("[SS] ", path)
  message("[OK] Prototipo SS non definitivo reso nel layout A4 verticale.")
}
