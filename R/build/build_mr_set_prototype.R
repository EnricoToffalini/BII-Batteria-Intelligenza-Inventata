#!/usr/bin/env Rscript

# Genera quattro prototipi non definitivi della famiglia set_combination di MR.
#
#   Rscript R/build/build_mr_set_prototype.R
#
# Ogni matrice occupa una tavola A4 separata per mantenere celle da 30 mm.
# I prototipi non sono item scored e non modificano la forma MR.

bii_mr_prototype_root <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) == 1L) {
    script <- normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE))
  }
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

mr_anchor_positions <- function() {
  data.frame(
    anchor = c("TL", "TC", "TR", "ML", "MC", "MR", "BL", "BC", "BR"),
    x = c(-7, 0, 7, -7, 0, 7, -7, 0, 7),
    y = c(-7, -7, -7, 0, 0, 0, 7, 7, 7),
    stringsAsFactors = FALSE
  )
}

mr_set_operation <- function(a, b, operation) {
  if (operation == "union") return(union(a, b))
  if (operation == "intersection") return(intersect(a, b))
  if (operation == "difference") return(setdiff(a, b))
  if (operation == "xor") return(union(setdiff(a, b), setdiff(b, a)))
  stop("Operazione MR non riconosciuta: ", operation, call. = FALSE)
}

mr_same_set <- function(a, b) identical(sort(unique(a)), sort(unique(b)))

mr_components_in <- function(source, prototype_id, panel, row = NULL, column = NULL, option = NULL) {
  keep <- source$prototype_id == prototype_id & source$panel == panel
  if (!is.null(row)) keep <- keep & source$row == row
  if (!is.null(column)) keep <- keep & source$column == column
  if (!is.null(option)) keep <- keep & source$option == option
  source$anchor[keep][order(source$layer[keep])]
}

validate_mr_set_prototype <- function(root) {
  source_path <- file.path(root, "items", "prototypes", "MR", "set_components.csv")
  key_path <- file.path(root, "items", "prototypes", "MR", "set_keys.csv")
  source <- utils::read.csv(source_path, stringsAsFactors = FALSE, check.names = FALSE)
  keys <- utils::read.csv(key_path, stringsAsFactors = FALSE, check.names = FALSE)

  source_names <- c("prototype_id", "panel", "row", "column", "option", "layer", "primitive", "anchor", "fill", "rotation", "status")
  key_names <- c("prototype_id", "operation", "correct_option", "option", "is_correct", "rationale")
  if (!identical(names(source), source_names)) stop("Colonne della sorgente MR non valide.", call. = FALSE)
  if (!identical(names(keys), key_names)) stop("Colonne della chiave MR non valide.", call. = FALSE)

  ids <- c("MR-P7P-U", "MR-P7P-I", "MR-P7P-D", "MR-P7P-X")
  operations <- c("union", "intersection", "difference", "xor")
  if (!setequal(unique(source$prototype_id), ids) || !setequal(unique(keys$prototype_id), ids)) {
    stop("P7P richiede esattamente quattro prototipi MR.", call. = FALSE)
  }
  if (any(!source$panel %in% c("matrix", "option"))) stop("Pannello MR non valido.", call. = FALSE)
  if (any(source$primitive != "dot") || any(source$fill != "filled") || any(source$rotation != 0)) {
    stop("P7P usa soltanto punti pieni senza rotazione.", call. = FALSE)
  }
  if (any(source$status != "non_definitive")) stop("I prototipi MR devono restare non definitivi.", call. = FALSE)
  if (!all(source$anchor %in% mr_anchor_positions()$anchor)) stop("Ancora MR non valida.", call. = FALSE)
  if (anyDuplicated(source[c("prototype_id", "panel", "row", "column", "option", "anchor")])) {
    stop("Componente MR duplicato nella stessa cella.", call. = FALSE)
  }
  if (any(is.na(keys$is_correct)) || any(!nzchar(keys$rationale))) stop("Chiave o rationale MR incompleti.", call. = FALSE)

  alternatives <- c("union", "intersection", "difference", "xor")
  for (i in seq_along(ids)) {
    id <- ids[i]
    item_source <- source[source$prototype_id == id, , drop = FALSE]
    item_keys <- keys[keys$prototype_id == id, , drop = FALSE]
    if (nrow(item_keys) != 5L || !setequal(item_keys$option, LETTERS[1:5])) stop("Alternative MR incomplete per ", id, ".", call. = FALSE)
    if (length(unique(item_keys$operation)) != 1L || unique(item_keys$operation) != operations[i]) stop("Operazione MR inattesa per ", id, ".", call. = FALSE)
    if (length(unique(item_keys$correct_option)) != 1L || sum(item_keys$is_correct) != 1L) stop("Chiave MR non univoca per ", id, ".", call. = FALSE)
    if (item_keys$option[item_keys$is_correct] != unique(item_keys$correct_option)) stop("Flag e chiave MR discordano per ", id, ".", call. = FALSE)

    matrix_rows <- item_source[item_source$panel == "matrix", , drop = FALSE]
    option_rows <- item_source[item_source$panel == "option", , drop = FALSE]
    observed_cells <- unique(matrix_rows[c("row", "column")])
    expected_cells <- expand.grid(row = 1:3, column = 1:3)
    expected_cells <- expected_cells[!(expected_cells$row == 3 & expected_cells$column == 3), ]
    if (!setequal(paste(observed_cells$row, observed_cells$column), paste(expected_cells$row, expected_cells$column))) {
      stop("Matrice incompleta o cella mancante errata per ", id, ".", call. = FALSE)
    }
    if (!setequal(unique(option_rows$option), LETTERS[1:5])) stop("Geometria delle alternative incompleta per ", id, ".", call. = FALSE)

    option_sets <- lapply(LETTERS[1:5], function(x) mr_components_in(source, id, "option", option = x))
    if (anyDuplicated(vapply(option_sets, function(x) paste(sort(x), collapse = ";"), character(1)))) {
      stop("Alternative geometriche duplicate per ", id, ".", call. = FALSE)
    }

    fits <- logical(length(alternatives))
    for (j in seq_along(alternatives)) {
      fits[j] <- TRUE
      for (row in 1:2) {
        a <- mr_components_in(source, id, "matrix", row = row, column = 1)
        b <- mr_components_in(source, id, "matrix", row = row, column = 2)
        result <- mr_components_in(source, id, "matrix", row = row, column = 3)
        fits[j] <- fits[j] && mr_same_set(mr_set_operation(a, b, alternatives[j]), result)
      }
    }
    if (sum(fits) != 1L || alternatives[fits] != operations[i]) {
      stop("Le righe osservate non identificano unicamente l'operazione per ", id, ".", call. = FALSE)
    }

    a <- mr_components_in(source, id, "matrix", row = 3, column = 1)
    b <- mr_components_in(source, id, "matrix", row = 3, column = 2)
    expected <- mr_set_operation(a, b, operations[i])
    matches <- vapply(option_sets, mr_same_set, logical(1), b = expected)
    if (sum(matches) != 1L || LETTERS[1:5][matches] != unique(item_keys$correct_option)) {
      stop("La risposta geometrica non coincide con la chiave per ", id, ".", call. = FALSE)
    }
  }

  list(source = source, keys = keys, ids = ids, operations = operations)
}

mr_dot_set_svg <- function(anchors, x, y, prototype_id, panel, position) {
  points <- mr_anchor_positions()
  points <- points[match(anchors, points$anchor), , drop = FALSE]
  dots <- sprintf('<circle cx="%.2f" cy="%.2f" r="2.05" fill="black"/>', x + points$x, y + points$y)
  sprintf('<g data-prototype-id="%s" data-panel="%s" data-position="%s">%s</g>', prototype_id, panel, position, paste(dots, collapse = ""))
}

mr_set_prototype_svg <- function(context, prototype_id) {
  source <- context$source
  review_id <- sprintf("MR-P7P-%02d", match(prototype_id, context$ids))
  cell <- 30
  matrix_x <- 60
  matrix_y <- 45
  parts <- c(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<svg xmlns="http://www.w3.org/2000/svg" width="210mm" height="297mm" viewBox="0 0 210 297">',
    '<rect width="210" height="297" fill="white"/>',
    '<g font-family="Arial, Helvetica, sans-serif" fill="black">',
    '<text x="18" y="17" font-size="5.2" font-weight="bold">MR - Matrici di Regole</text>',
    sprintf('<text x="18" y="24" font-size="3.0">PROTOTIPO %s NON DEFINITIVO - materiale didattico, non clinico</text>', review_id),
    '<text x="18" y="34" font-size="3.4">Quale alternativa completa la matrice?</text>'
  )

  for (row in 1:3) {
    for (column in 1:3) {
      x <- matrix_x + (column - 1) * cell
      y <- matrix_y + (row - 1) * cell
      parts <- c(parts, sprintf('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="white" stroke="black" stroke-width="0.45"/>', x, y, cell, cell))
      if (row == 3 && column == 3) {
        cx <- x + cell / 2
        cy <- y + cell / 2
        parts <- c(parts, sprintf('<path d="M %.1f %.1f L %.1f %.1f L %.1f %.1f L %.1f %.1f Z" fill="none" stroke="#555" stroke-width="0.55" data-missing-cell="true"/>', cx, cy - 4, cx + 4, cy, cx, cy + 4, cx - 4, cy))
      } else {
        anchors <- mr_components_in(source, prototype_id, "matrix", row = row, column = column)
        parts <- c(parts, mr_dot_set_svg(anchors, x + cell / 2, y + cell / 2, prototype_id, "matrix", paste0(row, "-", column)))
      }
    }
  }

  option_y <- 170
  option_x <- 20
  option_gap <- 4
  for (i in 1:5) {
    option <- LETTERS[i]
    x <- option_x + (i - 1) * (cell + option_gap)
    parts <- c(parts, sprintf('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="white" stroke="black" stroke-width="0.45"/>', x, option_y, cell, cell))
    anchors <- mr_components_in(source, prototype_id, "option", option = option)
    parts <- c(parts, mr_dot_set_svg(anchors, x + cell / 2, option_y + cell / 2, prototype_id, "option", option))
    parts <- c(parts, sprintf('<text x="%.1f" y="207" font-size="4.0" text-anchor="middle" font-weight="bold">%s</text>', x + cell / 2, option))
  }

  parts <- c(
    parts,
    '<text x="18" y="252" font-size="2.8" fill="#555">Tavola di review: la regola non e indicata sul foglio.</text>',
    '<text x="18" y="266" font-size="2.7">Stampare al 100%. Verificare la barra prima di valutare dimensioni e leggibilita.</text>',
    '<line x1="18" y1="276" x2="68" y2="276" stroke="black" stroke-width="0.55"/>',
    '<line x1="18" y1="273.5" x2="18" y2="278.5" stroke="black" stroke-width="0.55"/>',
    '<line x1="68" y1="273.5" x2="68" y2="278.5" stroke="black" stroke-width="0.55"/>',
    '<text x="43" y="283" font-size="2.8" text-anchor="middle">50 mm</text>',
    sprintf('<text x="192" y="283" font-size="2.6" text-anchor="end">%s - A4 verticale</text>', review_id),
    '</g>',
    '</svg>'
  )
  paste(parts, collapse = "\n")
}

build_mr_set_prototype <- function(root, output_dir = file.path(root, "materials", "stimulus_books", "prototypes", "MR"), dpi = 300) {
  if (!requireNamespace("rsvg", quietly = TRUE)) stop("Il pacchetto R 'rsvg' e richiesto per renderizzare il prototipo MR.", call. = FALSE)
  if (!requireNamespace("magick", quietly = TRUE)) stop("Il pacchetto R 'magick' e richiesto per registrare la densita del prototipo MR.", call. = FALSE)
  context <- validate_mr_set_prototype(root)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  pixels <- round(c(210, 297) / 25.4 * dpi)
  paths <- character()
  for (id in context$ids) {
    suffix <- sub("MR-P7P-", "", id, fixed = TRUE)
    stem <- file.path(output_dir, paste0("MR_set_combination_", suffix, "_A4_portrait"))
    svg_path <- paste0(stem, ".svg")
    pdf_path <- paste0(stem, ".pdf")
    png_path <- paste0(stem, "_300dpi.png")
    writeBin(charToRaw(enc2utf8(mr_set_prototype_svg(context, id))), svg_path)
    rsvg::rsvg_pdf(svg_path, pdf_path)
    rsvg::rsvg_png(svg_path, png_path, width = pixels[1], height = pixels[2])
    magick::image_write(magick::image_read(png_path), png_path, density = paste0(dpi, "x", dpi))
    paths <- c(paths, svg_path, pdf_path, png_path)
  }
  paths
}

if (sys.nframe() == 0L) {
  root <- bii_mr_prototype_root()
  for (path in build_mr_set_prototype(root)) message("[MR] ", path)
  message("[OK] Quattro prototipi MR non definitivi resi su tavole A4 separate.")
}
