# QA automatico dei quattro prototipi set_combination di MR.

source(file.path(root, "R", "build", "build_mr_set_prototype.R"), local = TRUE)

context <- validate_mr_set_prototype(root)
stopifnot(
  length(context$ids) == 4L,
  identical(context$operations, c("union", "intersection", "difference", "xor")),
  nrow(context$keys) == 20L,
  sum(context$keys$is_correct) == 4L,
  setequal(context$keys$correct_option, c("A", "B", "C", "E"))
)

for (i in seq_along(context$ids)) {
  id <- context$ids[i]
  svg <- mr_set_prototype_svg(context, id)
  stopifnot(
    grepl('width="210mm" height="297mm" viewBox="0 0 210 297"', svg, fixed = TRUE),
    lengths(regmatches(svg, gregexpr('data-prototype-id=', svg, fixed = TRUE))) == 13L,
    lengths(regmatches(svg, gregexpr('data-missing-cell="true"', svg, fixed = TRUE))) == 1L,
    grepl("50 mm", svg, fixed = TRUE),
    !grepl("union", svg, fixed = TRUE),
    !grepl("intersection", svg, fixed = TRUE),
    !grepl("difference", svg, fixed = TRUE),
    !grepl(">xor<", tolower(svg), fixed = TRUE),
    grepl(sprintf("MR-P7P-%02d", i), svg, fixed = TRUE),
    !grepl(paste0("PROTOTIPO ", id), svg, fixed = TRUE)
  )
}

tmp_a <- tempfile("mr-set-prototype-a-")
tmp_b <- tempfile("mr-set-prototype-b-")
dir.create(tmp_a)
dir.create(tmp_b)
paths_a <- build_mr_set_prototype(root, output_dir = tmp_a)
paths_b <- build_mr_set_prototype(root, output_dir = tmp_b)
stopifnot(
  length(paths_a) == 12L,
  length(paths_b) == 12L,
  all(file.exists(paths_a)),
  all(file.exists(paths_b)),
  all(file.info(paths_a)$size > 0L),
  sum(grepl("\\.pdf$", paths_a)) == 4L
)

# Cairo inserisce nel PDF un timestamp di creazione: i byte possono quindi
# cambiare pur lasciando identica la pagina. SVG e PNG devono restare identici
# byte per byte; per i PDF si confronta il rendering e la dimensione A4.
stable <- !grepl("\\.pdf$", paths_a)
stopifnot(identical(
  unname(tools::md5sum(paths_a[stable])),
  unname(tools::md5sum(paths_b[stable]))
))
pdf_a <- paths_a[grepl("\\.pdf$", paths_a)]
pdf_b <- paths_b[grepl("\\.pdf$", paths_b)]
pdf_size <- do.call(rbind, lapply(pdf_a, pdftools::pdf_pagesize))
stopifnot(
  all(pdf_size$width == 210),
  all(pdf_size$height == 297),
  all(vapply(seq_along(pdf_a), function(i) {
    identical(pdftools::pdf_render_page(pdf_a[i], dpi = 72), pdftools::pdf_render_page(pdf_b[i], dpi = 72))
  }, logical(1)))
)

png_paths <- paths_a[grepl("png$", paths_a)]
png_info <- magick::image_info(magick::image_read(png_paths))
expected_pixels <- round(c(210, 297) / 25.4 * 300)
stopifnot(
  nrow(png_info) == 4L,
  all(png_info$width == expected_pixels[1]),
  all(png_info$height == expected_pixels[2])
)
