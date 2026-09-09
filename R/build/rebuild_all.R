#!/usr/bin/env Rscript

# Rebuild of legacy simulated artifacts. It is intentionally an orchestrator:
# each historical script clears its own environment and must run in a separate
# R process. A future item-level pipeline will replace this implementation.

file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(file_arg) != 1L) stop("Impossibile determinare il percorso di rebuild_all.R.")
script_path <- normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE)
root <- normalizePath(file.path(dirname(script_path), "..", ".."), winslash = "/", mustWork = TRUE)

rscript <- Sys.which("Rscript")
if (!nzchar(rscript)) stop("Rscript non trovato nel PATH.")

steps <- c(
  "R/0.Data generation.R",
  "R/1.Fitting.R",
  "R/2.Task_tables_norming.R",
  "R/3.Indices_tables_and_CFA.R"
)

old_wd <- setwd(root)
on.exit(setwd(old_wd), add = TRUE)

for (step in steps) {
  path <- file.path(root, step)
  if (!file.exists(path)) stop("Script di rebuild mancante: ", step)
  message("[BUILD] ", step)
  status <- system2(rscript, path, stdout = "", stderr = "")
  if (!identical(status, 0L)) stop("Build interrotta nello step: ", step)
}

message("[OK] Rebuild legacy completato.")
