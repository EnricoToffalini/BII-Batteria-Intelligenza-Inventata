# QA automatico del micro-prototipo CL. Il controllo legge i CSV versionati:
# modificare uno stimolo o una chiave resta quindi sottoposto agli stessi vincoli.

source(file.path(root, "R", "build", "build_cl_prototype.R"), local = TRUE)

context <- validate_cl_prototype(root)
response_counts <- table(context$keys$correct_response)
vocabulary <- enc2utf8(unlist(context$spec$symbol_vocabulary, use.names = FALSE))
tokens <- intToUtf8(c(0x25CB, 0x25B3, 0x25A1, 0x25C6, 0x002B, 0x2605), multiple = TRUE)
expected_p2_left <- enc2utf8(c(
  paste0(tokens[c(1, 2, 3, 4)], collapse = ""),
  paste0(tokens[c(2, 1, 4, 6)], collapse = ""),
  paste0(tokens[c(3, 4, 1, 5)], collapse = ""),
  paste0(tokens[c(5, 6, 1, 2)], collapse = ""),
  paste0(tokens[c(4, 3, 6, 5)], collapse = ""),
  paste0(tokens[c(5, 4, 6, 1)], collapse = "")
))
expected_p2_right <- enc2utf8(c(
  expected_p2_left[1],
  paste0(tokens[c(2, 1, 4, 5)], collapse = ""),
  paste0(tokens[c(6, 4, 1, 5)], collapse = ""),
  expected_p2_left[4],
  expected_p2_left[5],
  paste0(tokens[c(5, 3, 6, 1)], collapse = "")
))
p4 <- 7:14
stopifnot(
  nrow(context$stimuli) == 14L,
  nrow(context$keys) == 14L,
  identical(context$stimuli$prototype_id, sprintf("CL-P%02d", seq_len(14L))),
  identical(enc2utf8(context$stimuli$left_string[1:6]), expected_p2_left),
  identical(enc2utf8(context$stimuli$right_string[1:6]), expected_p2_right),
  identical(context$keys$correct_response[1:6], c("UGUALE", "DIVERSO", "DIVERSO", "UGUALE", "UGUALE", "DIVERSO")),
  identical(as.integer(context$keys$difference_position[1:6]), c(0L, 4L, 1L, 0L, 0L, 2L)),
  identical(names(response_counts), c("DIVERSO", "UGUALE")),
  identical(as.integer(response_counts), c(7L, 7L)),
  sum(context$mismatches[p4] == 0L) == 4L,
  sum(context$mismatches[p4] == 1L) == 4L,
  identical(sort(context$positions[p4][context$positions[p4] > 0L]), 1:4),
  setequal(names(context$primitives), vocabulary),
  !anyDuplicated(names(context$primitives)),
  !anyDuplicated(unname(context$primitives))
)

svg <- cl_layout_svg(context)
primitive_present <- vapply(
  unname(context$primitives),
  function(fragment) grepl(fragment, svg, fixed = TRUE),
  logical(1)
)
symbol_groups <- gregexpr('<g transform="translate(', svg, fixed = TRUE)[[1]]
stopifnot(
  grepl('width="297mm" height="210mm"', svg, fixed = TRUE),
  !grepl("Segoe UI Symbol", svg, fixed = TRUE),
  !grepl('width="420mm" height="297mm"', svg, fixed = TRUE),
  !grepl('width="3.4" height="3.4"', svg, fixed = TRUE),
  grepl("barra una sola lettera", svg, fixed = TRUE),
  grepl("14 stimoli non definitivi", svg, fixed = TRUE),
  grepl("50 mm", svg, fixed = TRUE),
  grepl("PROTOTIPO NON SCORATO", svg, fixed = TRUE),
  all(primitive_present),
  length(symbol_groups) == 8L * nrow(context$stimuli)
)

tmp <- tempfile("cl-prototype-")
dir.create(tmp)
paths <- build_cl_prototype(root, output_dir = tmp)
stopifnot(
  length(paths) == 3L,
  all(file.exists(paths)),
  all(file.info(paths)$size > 0L),
  sum(grepl("\\.pdf$", paths)) == 1L
)
pdf_size <- pdftools::pdf_pagesize(paths[grepl("\\.pdf$", paths)])
stopifnot(pdf_size$width[1] == 297, pdf_size$height[1] == 210)
