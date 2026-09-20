#!/usr/bin/env Rscript

# Rebuild of derived artifacts. It is intentionally an orchestrator: each
# script clears its own environment and must run in a separate R process.
#
# The first steps derive from spec/ and items/ and are the direction of travel.
# The later steps are the legacy aggregate-score pipeline, still in place until
# norms are regenerated from item-level simulation.

file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(file_arg) != 1L) stop("Impossibile determinare il percorso di rebuild_all.R.")
script_path <- normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE)
root <- normalizePath(file.path(dirname(script_path), "..", ".."), winslash = "/", mustWork = TRUE)

rscript <- Sys.which("Rscript")
if (!nzchar(rscript)) stop("Rscript non trovato nel PATH.")

steps <- c(
  # Derivati dalla spec e dall'item bank.
  "R/build/build_record_forms.R",
  "R/build/routing_qa.R",
  # Pipeline legacy su punteggi aggregati.
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
  # shQuote e necessario: sia i nomi di alcuni script sia il percorso del
  # repository possono contenere spazi, e senza citazione system2 li spezza in
  # argomenti separati.
  status <- system2(rscript, shQuote(path), stdout = "", stderr = "")
  if (!identical(status, 0L)) stop("Build interrotta nello step: ", step)
}

message("[OK] Rebuild legacy completato.")
