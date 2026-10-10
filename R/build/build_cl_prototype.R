#!/usr/bin/env Rscript

# Genera il rendering A4 revisionato del prototipo CL.
#
#   Rscript R/build/build_cl_prototype.R
#
# I quattordici stimoli sono non definitivi e vivono in items/prototypes/CL/. Lo script
# non crea items/source/CL.csv e non trasforma il prototipo in un item bank.

bii_cl_root <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) == 1L) {
    script <- normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE))
  }
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

cl_read_utf8_csv <- function(path) {
  # Su Windows fileEncoding="UTF-8" dipende dalla locale della sessione e può
  # troncare la prima riga contenente glifi. readLines() decodifica prima il
  # testo, come fa il loader YAML della spec.
  lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
  utils::read.csv(text = paste(lines, collapse = "\n"), stringsAsFactors = FALSE, check.names = FALSE)
}

cl_chars <- function(x) strsplit(enc2utf8(x), "", fixed = TRUE)[[1]]

cl_symbol_primitives <- function() {
  # Ogni token semantico ha una sola primitiva, centrata nella stessa bounding
  # box nominale 4 x 4. Il renderer applica soltanto traslazione e scala.
  stats::setNames(
    c(
      '<circle cx="0" cy="0" r="1.55" fill="none" stroke="black" stroke-width="0.45"/>',
      '<polygon points="0,-1.70 1.65,1.35 -1.65,1.35" fill="none" stroke="black" stroke-width="0.45" stroke-linejoin="round"/>',
      '<rect x="-1.50" y="-1.50" width="3.00" height="3.00" fill="none" stroke="black" stroke-width="0.45"/>',
      '<polygon points="0,-1.70 1.70,0 0,1.70 -1.70,0" fill="black"/>',
      '<path d="M -1.55 0 H 1.55 M 0 -1.55 V 1.55" fill="none" stroke="black" stroke-width="0.55" stroke-linecap="square"/>',
      '<path d="M 0,-1.75 L 0.411,-0.566 L 1.664,-0.541 L 0.665,0.216 L 1.029,1.416 L 0,0.700 L -1.029,1.416 L -0.665,0.216 L -1.664,-0.541 L -0.411,-0.566 Z" fill="black"/>'
    ),
    intToUtf8(c(0x25CB, 0x25B3, 0x25A1, 0x25C6, 0x002B, 0x2605), multiple = TRUE)
  )
}

cl_symbol <- function(x, y, token, size = 4.0, primitives = cl_symbol_primitives()) {
  token <- enc2utf8(token)
  if (length(token) != 1L || is.na(primitives[token])) {
    stop("Token CL privo di primitiva SVG: ", token, call. = FALSE)
  }
  sprintf(
    '<g transform="translate(%.3f %.3f) scale(%.4f)">%s</g>',
    x, y, size / 4.0, unname(primitives[token])
  )
}

validate_cl_prototype <- function(root) {
  if (!exists("read_bii_spec", mode = "function")) {
    source(file.path(root, "R", "spec", "load_spec.R"), local = TRUE)
  }
  spec <- read_bii_spec(root)
  st <- spec$subtests$CL
  source_path <- file.path(root, "items", "prototypes", "CL", "distinct_substitution.csv")
  key_path <- file.path(root, "items", "prototypes", "CL", "distinct_substitution_keys.csv")
  stimuli <- cl_read_utf8_csv(source_path)
  keys <- cl_read_utf8_csv(key_path)

  required_stimuli <- c("prototype_id", "family", "left_string", "right_string", "status")
  required_keys <- c("prototype_id", "correct_response", "difference_position")
  if (!identical(names(stimuli), required_stimuli)) stop("Colonne del prototipo CL non valide.", call. = FALSE)
  if (!identical(names(keys), required_keys)) stop("Colonne della chiave CL non valide.", call. = FALSE)
  if (nrow(stimuli) != 14L || nrow(keys) != 14L) stop("P4 richiede i sei prototipi P2 più un lotto di otto.", call. = FALSE)
  if (anyDuplicated(stimuli$prototype_id) || anyDuplicated(keys$prototype_id)) stop("ID prototipo duplicato.", call. = FALSE)
  expected_ids <- sprintf("CL-P%02d", seq_len(14L))
  if (!identical(stimuli$prototype_id, expected_ids)) stop("Gli ID CL devono essere ordinati da CL-P01 a CL-P14.", call. = FALSE)
  if (!setequal(stimuli$prototype_id, keys$prototype_id)) stop("Stimoli e chiavi hanno ID diversi.", call. = FALSE)
  keys <- keys[match(stimuli$prototype_id, keys$prototype_id), , drop = FALSE]

  vocabulary <- enc2utf8(unlist(st$symbol_vocabulary, use.names = FALSE))
  if (length(vocabulary) != 6L || anyDuplicated(vocabulary)) stop("Vocabolario CL non valido nella spec.", call. = FALSE)
  primitives <- cl_symbol_primitives()
  if (!setequal(names(primitives), vocabulary)) stop("Vocabolario CL e primitive SVG non corrispondono.", call. = FALSE)
  if (anyDuplicated(unname(primitives))) stop("Ogni token CL deve avere una primitiva SVG distinta.", call. = FALSE)
  if (any(stimuli$family != "distinct_substitution")) stop("P4 deve contenere una sola famiglia.", call. = FALSE)
  if (any(stimuli$status != "non_definitive")) stop("Gli stimoli P4 devono restare non definitivi.", call. = FALSE)
  if (anyDuplicated(paste(stimuli$left_string, stimuli$right_string, sep = "\r"))) stop("Coppia di stringhe duplicata nel prototipo CL.", call. = FALSE)

  observed <- character()
  observed_by_item <- vector("list", nrow(stimuli))
  mismatches <- integer(nrow(stimuli))
  positions <- integer(nrow(stimuli))
  for (i in seq_len(nrow(stimuli))) {
    left <- cl_chars(stimuli$left_string[i])
    right <- cl_chars(stimuli$right_string[i])
    if (length(left) != 4L || length(right) != 4L) stop(stimuli$prototype_id[i], ": stringa non lunga quattro.", call. = FALSE)
    if (length(unique(left)) != 4L) stop(stimuli$prototype_id[i], ": la famiglia baseline richiede quattro simboli distinti.", call. = FALSE)
    if (length(unique(right)) != 4L) stop(stimuli$prototype_id[i], ": la sostituzione non deve creare simboli duplicati.", call. = FALSE)
    if (!all(c(left, right) %in% vocabulary)) stop(stimuli$prototype_id[i], ": simbolo fuori vocabolario.", call. = FALSE)
    observed <- c(observed, left, right)
    observed_by_item[[i]] <- c(left, right)
    different <- which(left != right)
    mismatches[i] <- length(different)
    positions[i] <- if (length(different)) different else 0L
  }

  expected_response <- ifelse(mismatches == 0L, "UGUALE", "DIVERSO")
  if (!identical(keys$correct_response, expected_response)) stop("Chiave uguale/diverso incoerente con gli stimoli.", call. = FALSE)
  if (!identical(as.integer(keys$difference_position), positions)) stop("Posizione della differenza incoerente.", call. = FALSE)
  p2 <- seq_len(6L)
  p4 <- 7:14
  if (sum(mismatches[p2] == 0L) != 3L || sum(mismatches[p2] == 1L) != 3L) stop("P2 deve conservare tre coppie uguali e tre diverse.", call. = FALSE)
  if (!identical(sort(positions[p2][positions[p2] > 0L]), c(1L, 2L, 4L))) stop("Le differenze P2 devono restare nelle posizioni 1, 2 e 4.", call. = FALSE)
  if (sum(mismatches[p4] == 0L) != 4L || sum(mismatches[p4] == 1L) != 4L) stop("P4 richiede quattro coppie uguali e quattro diverse.", call. = FALSE)
  if (!identical(sort(positions[p4][positions[p4] > 0L]), 1:4)) stop("Il lotto P4 deve esercitare una volta ciascuna posizione di differenza.", call. = FALSE)
  if (!setequal(unique(unlist(observed_by_item[p4], use.names = FALSE)), vocabulary)) stop("Il lotto P4 non esercita tutto il vocabolario dichiarato.", call. = FALSE)
  key_runs <- rle(keys$correct_response)$lengths
  if (any(key_runs > 2L) || all(keys$correct_response[-1L] != keys$correct_response[-nrow(keys)])) stop("Sequenza delle chiavi CL troppo prevedibile.", call. = FALSE)
  if (!setequal(unique(observed), vocabulary)) stop("Il prototipo non esercita tutto il vocabolario dichiarato.", call. = FALSE)

  list(stimuli = stimuli, keys = keys, spec = st, primitives = primitives, mismatches = mismatches, positions = positions)
}

cl_xml_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x
}

cl_text <- function(x, y, value, size, anchor = "middle", weight = "normal", family = "Arial") {
  sprintf(
    '<text x="%.3f" y="%.3f" text-anchor="%s" dominant-baseline="middle" font-family="%s" font-size="%.3f" font-weight="%s">%s</text>',
    x, y, anchor, family, size, weight, cl_xml_escape(value)
  )
}

cl_layout_svg <- function(context) {
  page <- c(width = 297, height = 210)
  margin <- 10
  gutter <- 4
  n_columns <- 4L
  n_rows <- 25L
  block_width <- (page[["width"]] - 2 * margin - (n_columns - 1L) * gutter) / n_columns
  row_top <- 34
  row_bottom <- page[["height"]] - 14
  row_height <- (row_bottom - row_top) / n_rows
  symbol_size <- 4.0
  cell_step <- 4.2

  svg <- c(
    '<?xml version="1.0" encoding="UTF-8"?>',
    sprintf('<svg xmlns="http://www.w3.org/2000/svg" width="%gmm" height="%gmm" viewBox="0 0 %g %g">', page[["width"]], page[["height"]], page[["width"]], page[["height"]]),
    '<metadata>CL P4; formato A4 orizzontale; scala 100%; famiglia distinct_substitution; 14 stimoli non definitivi; glifi SVG deterministici</metadata>',
    '<rect x="0" y="0" width="100%" height="100%" fill="white"/>',
    cl_text(margin, 10, "CL - PROTOTIPO NON SCORATO", 5.0, anchor = "start", weight = "bold"),
    cl_text(page[["width"]] - margin, 10, "A4 orizzontale - stampa 100%", 3.2, anchor = "end"),
    cl_text(margin, 17, "Confronta le stringhe e barra una sola lettera: U = UGUALE, D = DIVERSO.", 3.4, anchor = "start")
  )

  for (column in seq_len(n_columns)) {
    x0 <- margin + (column - 1L) * (block_width + gutter)
    response_u <- x0 + block_width - 14
    response_d <- x0 + block_width - 6
    svg <- c(
      svg,
      cl_text(x0 + 2, 27, as.character(column), 3.0, anchor = "start", weight = "bold"),
      cl_text(response_u, 27, "U", 3.2, weight = "bold"),
      cl_text(response_d, 27, "D", 3.2, weight = "bold"),
      sprintf('<rect x="%.3f" y="%.3f" width="%.3f" height="%.3f" fill="none" stroke="#777" stroke-width="0.25"/>', x0, row_top, block_width, row_bottom - row_top)
    )
    for (row in seq_len(n_rows - 1L)) {
      y <- row_top + row * row_height
      svg <- c(svg, sprintf('<line x1="%.3f" y1="%.3f" x2="%.3f" y2="%.3f" stroke="#dddddd" stroke-width="0.18"/>', x0, y, x0 + block_width, y))
    }
    svg <- c(svg, cl_text(x0 + block_width / 2, row_bottom + 4, if (column < n_columns) "CONTINUA ->" else "FINE", 2.8, weight = "bold"))
  }

  # I quattordici stimoli occupano soltanto l'inizio della prima colonna. Le altre
  # righe sono guide di densita, non item fittizi.
  x0 <- margin
  stimulus_space <- block_width - 20
  left_start <- x0 + 4 + max(0, (stimulus_space - 36) / 2)
  separator_x <- left_start + 18
  right_start <- left_start + 21
  response_u <- x0 + block_width - 14
  response_d <- x0 + block_width - 6
  for (i in seq_len(nrow(context$stimuli))) {
    y <- row_top + (i - 0.5) * row_height
    left <- cl_chars(context$stimuli$left_string[i])
    right <- cl_chars(context$stimuli$right_string[i])
    svg <- c(svg, cl_text(x0 + 2.5, y, as.character(i), 2.7))
    for (position in 0:3) {
      svg <- c(
        svg,
        cl_symbol(left_start + position * cell_step, y, left[position + 1L], symbol_size, context$primitives),
        cl_symbol(right_start + position * cell_step, y, right[position + 1L], symbol_size, context$primitives)
      )
    }
    svg <- c(
      svg,
      sprintf('<line x1="%.3f" y1="%.3f" x2="%.3f" y2="%.3f" stroke="#999" stroke-width="0.3"/>', separator_x, y - 2.1, separator_x, y + 2.1),
      cl_text(response_u, y, "U", 3.4, weight = "bold"),
      cl_text(response_d, y, "D", 3.4, weight = "bold")
    )
  }

  # Barra fisica per controllare che il viewer o la stampante non riscalino.
  scale_x <- page[["width"]] - margin - 50
  scale_y <- 20
  svg <- c(
    svg,
    sprintf('<line x1="%.3f" y1="%.3f" x2="%.3f" y2="%.3f" stroke="black" stroke-width="0.5"/>', scale_x, scale_y, scale_x + 50, scale_y),
    sprintf('<line x1="%.3f" y1="%.3f" x2="%.3f" y2="%.3f" stroke="black" stroke-width="0.5"/>', scale_x, scale_y - 1.5, scale_x, scale_y + 1.5),
    sprintf('<line x1="%.3f" y1="%.3f" x2="%.3f" y2="%.3f" stroke="black" stroke-width="0.5"/>', scale_x + 50, scale_y - 1.5, scale_x + 50, scale_y + 1.5),
    cl_text(scale_x + 25, scale_y - 2.5, "50 mm", 2.7),
    '</svg>'
  )
  paste(svg, collapse = "\n")
}

build_cl_prototype <- function(root, output_dir = file.path(root, "materials", "stimulus_books", "prototypes", "CL"), dpi = 300) {
  if (!requireNamespace("rsvg", quietly = TRUE)) stop("Il pacchetto R 'rsvg' è richiesto per renderizzare il prototipo CL.", call. = FALSE)
  if (!requireNamespace("magick", quietly = TRUE)) stop("Il pacchetto R 'magick' è richiesto per registrare la densità di stampa del prototipo CL.", call. = FALSE)

  context <- validate_cl_prototype(root)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  stem <- file.path(output_dir, "CL_distinct_substitution_A4_landscape")
  svg_path <- paste0(stem, ".svg")
  pdf_path <- paste0(stem, ".pdf")
  png_path <- paste0(stem, "_300dpi.png")
  # Scrittura binaria dei byte UTF-8: la locale C.UTF-8 non è disponibile in
  # alcune sessioni R su Windows e una text connection trasformerebbe i glifi
  # in stringhe letterali come <U+25CB>, che rompono anche l'XML.
  writeBin(charToRaw(enc2utf8(cl_layout_svg(context))), svg_path)
  rsvg::rsvg_pdf(svg_path, pdf_path)
  pixels <- round(c(297, 210) / 25.4 * dpi)
  rsvg::rsvg_png(svg_path, png_path, width = pixels[1], height = pixels[2])
  magick::image_write(magick::image_read(png_path), png_path, density = paste0(dpi, "x", dpi))
  c(svg_path, pdf_path, png_path)
}

if (sys.nframe() == 0L) {
  root <- bii_cl_root()
  for (path in build_cl_prototype(root)) message("[CL] ", path)
  message("[OK] Quattordici prototipi non definitivi resi nel layout A4.")
}
