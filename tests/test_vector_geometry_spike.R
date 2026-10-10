# QA automatico dello spike non scored P6.

source(file.path(root, "R", "build", "build_vector_geometry_spike.R"), local = TRUE)

svg <- vector_geometry_spike_svg()
stopifnot(validate_vector_geometry_spike(svg))
stopifnot(
  lengths(regmatches(svg, gregexpr('data-check=', svg, fixed = TRUE))) == 6L,
  lengths(regmatches(svg, gregexpr('data-transform=', svg, fixed = TRUE))) == 4L,
  !grepl("<image", svg, fixed = TRUE),
  grepl('stroke-width="0.25"', svg, fixed = TRUE),
  grepl('stroke-width="0.40"', svg, fixed = TRUE),
  grepl('stroke-width="0.60"', svg, fixed = TRUE)
)

tmp <- tempfile("vector-spike-")
dir.create(tmp)
paths <- build_vector_geometry_spike(root, output_dir = tmp)
stopifnot(length(paths) == 2L, all(file.exists(paths)), all(file.info(paths)$size > 0L))

png_info <- magick::image_info(magick::image_read(paths[grepl("png$", paths)]))
expected_pixels <- round(c(210, 297) / 25.4 * 300)
stopifnot(
  png_info$width == expected_pixels[1],
  png_info$height == expected_pixels[2]
)
