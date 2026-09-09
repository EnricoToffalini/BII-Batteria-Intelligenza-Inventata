#!/usr/bin/env Rscript

# Entry point deliberately based on base R so it remains usable before the
# project adopts a test framework. Test files must stop() on failure.

options(warn = 2)

root <- normalizePath(".", winslash = "/", mustWork = TRUE)
required_root_files <- c(
  "AGENTS.md",
  "ROADMAP_V0.md",
  "README.md",
  "CHANGELOG.md",
  "_BII - Batteria Intelligenza Inventata.md"
)

missing <- required_root_files[!file.exists(file.path(root, required_root_files))]
if (length(missing) > 0L) {
  stop("File obbligatori mancanti: ", paste(missing, collapse = ", "))
}

test_files <- list.files(
  file.path(root, "tests"),
  pattern = "^test_.*\\.R$",
  full.names = TRUE
)

if (length(test_files) == 0L) stop("Nessun file test_*.R trovato in tests/.")

for (test_file in sort(test_files)) {
  message("[TEST] ", sub(paste0("^", root, "/"), "", test_file))
  test_env <- new.env(parent = baseenv())
  assign("root", root, envir = test_env)
  source(test_file, local = test_env)
}

message("[OK] ", length(test_files), " test file(s) completed.")
