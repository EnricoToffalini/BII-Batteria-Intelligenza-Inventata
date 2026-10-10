# QA automatico del prototipo ridotto SS.

source(file.path(root, "R", "build", "build_ss_prototype.R"), local = TRUE)

context <- validate_ss_prototype(root)
expected_practice <- c(
  "circle_vertical", "circle_horizontal", "circle_vertical", "square_vertical",
  "square_horizontal", "circle_vertical", "triangle_vertical", "circle_vertical",
  "triangle_horizontal", "circle_vertical", "circle_horizontal", "circle_vertical"
)
stopifnot(
  nrow(context$cells) == 72L,
  sum(context$practice) == 12L,
  sum(context$prototype) == 60L,
  sum(context$keys$is_target[context$practice]) == 6L,
  sum(context$keys$is_target[context$prototype]) == 30L,
  identical(names(ss_symbol_primitives()), unlist(context$spec$symbol_vocabulary, use.names = FALSE)),
  identical(context$cells$token[context$practice], expected_practice),
  identical(as.integer(colSums(context$target_matrix)), c(3L, 4L, 2L, 3L, 3L, 4L, 2L, 2L, 3L, 4L)),
  all(apply(context$target_matrix, 1, ss_max_alternating_run) <= 5L)
)

svg <- ss_layout_svg(context)
stopifnot(
  grepl('width="210mm" height="297mm" viewBox="0 0 210 297"', svg, fixed = TRUE),
  lengths(regmatches(svg, gregexpr('data-stimulus-id=', svg, fixed = TRUE))) == 72L,
  grepl("Matrice prototipo - 6 righe su 20", svg, fixed = TRUE),
  grepl("50 mm", svg, fixed = TRUE)
)

tmp <- tempfile("ss-prototype-")
dir.create(tmp)
paths <- build_ss_prototype(root, output_dir = tmp)
stopifnot(
  length(paths) == 3L,
  all(file.exists(paths)),
  all(file.info(paths)$size > 0L),
  sum(grepl("\\.pdf$", paths)) == 1L
)
pdf_size <- pdftools::pdf_pagesize(paths[grepl("\\.pdf$", paths)])
stopifnot(pdf_size$width[1] == 210, pdf_size$height[1] == 297)

png_info <- magick::image_info(magick::image_read(paths[grepl("png$", paths)]))
expected_pixels <- round(c(210, 297) / 25.4 * 300)
stopifnot(
  png_info$width == expected_pixels[1],
  png_info$height == expected_pixels[2]
)
