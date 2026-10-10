#!/usr/bin/env Rscript

# Spike non scored della pipeline vector_geometry.
#
#   Rscript R/build/build_vector_geometry_spike.R
#
# La tavola calibra sorgente, rendering e scala di stampa. Non contiene item e
# non definisce la grammatica visiva di MR, RP, MP o DM.

bii_vector_spike_root <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) == 1L) {
    script <- normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE))
  }
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

vector_geometry_spike_svg <- function() {
  svg <- c(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<svg xmlns="http://www.w3.org/2000/svg" width="210mm" height="297mm" viewBox="0 0 210 297">',
    '<rect width="210" height="297" fill="white"/>',
    '<g font-family="Arial, Helvetica, sans-serif" fill="black">',
    '<text x="15" y="16" font-size="5.2" font-weight="bold">BII vector geometry - capability spike P6</text>',
    '<text x="15" y="23" font-size="3.0">NON SCORED - pipeline calibration only - print at 100%</text>',

    '<g data-check="stroke-panel">',
    '<rect x="15" y="32" width="180" height="48" fill="none" stroke="#999" stroke-width="0.25"/>',
    '<text x="20" y="40" font-size="3.4" font-weight="bold">A. Stroke and primitive scale</text>',
    '<line x1="25" y1="49" x2="80" y2="49" stroke="black" stroke-width="0.25"/>',
    '<text x="85" y="50" font-size="2.8">0.25 mm</text>',
    '<line x1="25" y1="58" x2="80" y2="58" stroke="black" stroke-width="0.40"/>',
    '<text x="85" y="59" font-size="2.8">0.40 mm</text>',
    '<line x1="25" y1="67" x2="80" y2="67" stroke="black" stroke-width="0.60"/>',
    '<text x="85" y="68" font-size="2.8">0.60 mm</text>',
    '<circle cx="132" cy="58" r="10" fill="none" stroke="black" stroke-width="0.40"/>',
    '<rect x="151" y="48" width="20" height="20" fill="none" stroke="black" stroke-width="0.40"/>',
    '<polygon points="183,47 194,68 172,68" fill="none" stroke="black" stroke-width="0.40" stroke-linejoin="round"/>',
    '</g>',

    '<g data-check="transform-panel">',
    '<rect x="15" y="88" width="180" height="62" fill="none" stroke="#999" stroke-width="0.25"/>',
    '<text x="20" y="96" font-size="3.4" font-weight="bold">B. Deterministic transforms of one asymmetric source</text>',
    '<defs><g id="asymmetric-source"><path d="M -10 -8 H 4 V -3 H 10 V 8 H -3 V 3 H -10 Z" fill="none" stroke="black" stroke-width="0.55" stroke-linejoin="round"/><circle cx="4" cy="3" r="2.2" fill="black"/></g></defs>',
    '<g transform="translate(39 121)" data-transform="identity"><use href="#asymmetric-source"/></g>',
    '<g transform="translate(82 121) rotate(90)" data-transform="rotate-90"><use href="#asymmetric-source"/></g>',
    '<g transform="translate(125 121) scale(-1 1)" data-transform="reflect-x"><use href="#asymmetric-source"/></g>',
    '<g transform="translate(168 121) rotate(180)" data-transform="rotate-180"><use href="#asymmetric-source"/></g>',
    '<text x="39" y="143" font-size="2.7" text-anchor="middle">source</text>',
    '<text x="82" y="143" font-size="2.7" text-anchor="middle">rotate 90</text>',
    '<text x="125" y="143" font-size="2.7" text-anchor="middle">reflect x</text>',
    '<text x="168" y="143" font-size="2.7" text-anchor="middle">rotate 180</text>',
    '</g>',

    '<g data-check="occlusion-panel">',
    '<rect x="15" y="158" width="180" height="48" fill="none" stroke="#999" stroke-width="0.25"/>',
    '<text x="20" y="166" font-size="3.4" font-weight="bold">C. Joins, overlap and clipping</text>',
    '<path d="M 27 194 L 38 174 L 49 194 Z" fill="none" stroke="black" stroke-width="0.50" stroke-linejoin="miter"/>',
    '<path d="M 62 194 L 73 174 L 84 194 Z" fill="none" stroke="black" stroke-width="0.50" stroke-linejoin="round"/>',
    '<circle cx="110" cy="184" r="11" fill="white" stroke="black" stroke-width="0.50"/>',
    '<rect x="106" y="175" width="18" height="18" fill="white" stroke="black" stroke-width="0.50"/>',
    '<clipPath id="circle-clip"><circle cx="158" cy="184" r="11"/></clipPath>',
    '<circle cx="158" cy="184" r="11" fill="white" stroke="black" stroke-width="0.50"/>',
    '<g clip-path="url(#circle-clip)" stroke="black" stroke-width="0.35">',
    '<line x1="143" y1="174" x2="166" y2="197"/><line x1="148" y1="169" x2="171" y2="192"/><line x1="153" y1="166" x2="174" y2="187"/>',
    '</g>',
    '<circle cx="158" cy="184" r="11" fill="none" stroke="black" stroke-width="0.50"/>',
    '</g>',

    '<g data-check="layout-panel">',
    '<rect x="15" y="214" width="180" height="47" fill="none" stroke="#999" stroke-width="0.25"/>',
    '<text x="20" y="222" font-size="3.4" font-weight="bold">D. Equal answer slots (no correct answer)</text>',
    '<g fill="none" stroke="black" stroke-width="0.50">',
    '<circle cx="37" cy="242" r="9"/><path d="M 31 242 H 43 M 37 236 V 248"/>',
    '<rect x="73" y="233" width="18" height="18"/><path d="M 76 248 L 88 236"/>',
    '<polygon points="126,232 136,251 116,251" stroke-linejoin="round"/><circle cx="126" cy="244" r="2"/>',
    '<path d="M 155 233 H 173 V 251 H 155 Z M 159 237 L 169 247 M 169 237 L 159 247"/>',
    '</g>',
    '<text x="37" y="257" font-size="2.7" text-anchor="middle">A</text>',
    '<text x="82" y="257" font-size="2.7" text-anchor="middle">B</text>',
    '<text x="126" y="257" font-size="2.7" text-anchor="middle">C</text>',
    '<text x="164" y="257" font-size="2.7" text-anchor="middle">D</text>',
    '</g>',

    '<line x1="15" y1="275" x2="65" y2="275" stroke="black" stroke-width="0.55" data-check="scale-bar"/>',
    '<line x1="15" y1="272.5" x2="15" y2="277.5" stroke="black" stroke-width="0.55"/>',
    '<line x1="65" y1="272.5" x2="65" y2="277.5" stroke="black" stroke-width="0.55"/>',
    '<text x="40" y="282" font-size="2.8" text-anchor="middle">50 mm</text>',
    '<rect x="159" y="270" width="20" height="10" fill="none" stroke="black" stroke-width="0.40" data-check="dimension-box"/>',
    '<text x="169" y="285" font-size="2.7" text-anchor="middle">20 x 10 mm</text>',
    '</g>',
    '</svg>'
  )
  paste(svg, collapse = "\n")
}

validate_vector_geometry_spike <- function(svg) {
  required <- c(
    'width="210mm" height="297mm" viewBox="0 0 210 297"',
    'data-check="stroke-panel"',
    'data-check="transform-panel"',
    'data-check="occlusion-panel"',
    'data-check="layout-panel"',
    'data-check="scale-bar"',
    'data-check="dimension-box"',
    'data-transform="identity"',
    'data-transform="rotate-90"',
    'data-transform="reflect-x"',
    'data-transform="rotate-180"'
  )
  if (!all(vapply(required, grepl, logical(1), x = svg, fixed = TRUE))) {
    stop("Tavola P6 incompleta.", call. = FALSE)
  }
  if (grepl("<image", svg, fixed = TRUE)) stop("P6 non deve incorporare raster nello SVG.", call. = FALSE)
  invisible(TRUE)
}

build_vector_geometry_spike <- function(root, output_dir = file.path(root, "materials", "stimulus_books", "prototypes", "vector_geometry"), dpi = 300) {
  if (!requireNamespace("rsvg", quietly = TRUE)) stop("Il pacchetto R 'rsvg' è richiesto per P6.", call. = FALSE)
  if (!requireNamespace("magick", quietly = TRUE)) stop("Il pacchetto R 'magick' è richiesto per P6.", call. = FALSE)
  svg <- vector_geometry_spike_svg()
  validate_vector_geometry_spike(svg)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  stem <- file.path(output_dir, "vector_geometry_spike_A4_portrait")
  svg_path <- paste0(stem, ".svg")
  png_path <- paste0(stem, "_300dpi.png")
  writeBin(charToRaw(enc2utf8(svg)), svg_path)
  pixels <- round(c(210, 297) / 25.4 * dpi)
  rsvg::rsvg_png(svg_path, png_path, width = pixels[1], height = pixels[2])
  magick::image_write(magick::image_read(png_path), png_path, density = paste0(dpi, "x", dpi))
  c(svg_path, png_path)
}

if (sys.nframe() == 0L) {
  root <- bii_vector_spike_root()
  for (path in build_vector_geometry_spike(root)) message("[P6] ", path)
  message("[OK] Capability spike vector_geometry reso in A4 verticale.")
}
