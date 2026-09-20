# Interfaccia SP (Significato delle Parole).
#
# Le regole di somministrazione e scoring non sono piu duplicate qui: SP usa
# il motore generico di R/scoring/administer.R, che legge spec/subtests/SP.yml.
# Questo file resta come scorciatoia leggibile per chi lavora solo su SP e per
# i materiali che lo citano.

if (!exists("route_subtest", mode = "function")) {
  .bii_sp_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(.bii_sp_root, "R", "scoring", "administer.R"))) break
    .bii_sp_parent <- dirname(.bii_sp_root)
    if (identical(.bii_sp_parent, .bii_sp_root)) stop("Repository BII non trovato.", call. = FALSE)
    .bii_sp_root <- .bii_sp_parent
  }
  source(file.path(.bii_sp_root, "R", "scoring", "administer.R"), local = TRUE)
}

sp_find_root <- function(start = getwd()) bii_find_root(start)

load_sp <- function(root = NULL) load_item_bank("SP", root)

sp_start_item <- function(age_months, sp_spec) subtest_start_item(age_months, sp_spec)

route_sp <- function(complete_scores, age_months, root = NULL) {
  route_subtest("SP", complete_scores, age_months, root)
}

score_sp_record <- function(records, root = NULL) {
  score_subtest_record("SP", records, root)
}
