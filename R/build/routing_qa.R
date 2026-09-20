#!/usr/bin/env Rscript

# Report di QA sulle regole adattive.
#
# Risponde alla domanda della fase 4 della roadmap: le regole di start point,
# inversione e interruzione dichiarate nella spec producono un comportamento
# plausibile su una popolazione simulata?
#
#   Rscript R/build/routing_qa.R
#
# Il report NON contiene norme. I difficulty_target sono ipotesi progettuali e
# il modello generativo e una scelta didattica dichiarata, non una stima.

BII_ROUTING_QA_SEED <- 20260912L
BII_ROUTING_QA_N <- 4000L

bii_qa_root <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) == 1L) {
    script <- normalizePath(sub("^--file=", "", file_arg), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE))
  }
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

# Hash della spec: permette di capire se un report e stato prodotto prima o
# dopo una modifica alla fonte di verita.
bii_spec_hash <- function(root) {
  files <- sort(c(
    file.path(root, "spec", "battery.yml"),
    list.files(file.path(root, "spec", "subtests"), pattern = "\\.ya?ml$", full.names = TRUE)
  ))
  content <- unlist(lapply(files, readLines, encoding = "UTF-8", warn = FALSE))
  if (requireNamespace("tools", quietly = TRUE)) {
    tmp <- tempfile()
    on.exit(unlink(tmp), add = TRUE)
    writeLines(content, tmp)
    return(unname(tools::md5sum(tmp)))
  }
  NA_character_
}

bii_git_sha <- function(root) {
  sha <- tryCatch(
    system2("git", c("-C", shQuote(root), "rev-parse", "--short", "HEAD"), stdout = TRUE, stderr = FALSE),
    error = function(e) character(0), warning = function(w) character(0)
  )
  if (length(sha) == 1L && nzchar(sha)) sha else "non disponibile"
}

# Comportamento del routing per fascia di eta: serve a vedere se i punti di
# partenza sono tarati o se producono inversioni sistematiche.
routing_by_age_band <- function(simulated, battery) {
  bands <- battery$norming$index_age_groups
  rows <- lapply(bands, function(band) {
    keep <- simulated$age_months >= band$min_months & simulated$age_months <= band$max_months
    if (!any(keep)) return(NULL)
    x <- simulated[keep, , drop = FALSE]
    data.frame(
      band = band$id,
      n = nrow(x),
      mean_raw = round(mean(x$raw_score), 2),
      mean_items = round(mean(x$n_administered), 1),
      inversion_rate = round(mean(x$inversion_applied), 3),
      ceiling_rate = round(mean(x$ceiling_reached), 3),
      floor_rate = round(mean(x$raw_score == 0), 3),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

md_table <- function(df) {
  header <- paste0("| ", paste(names(df), collapse = " | "), " |")
  divider <- paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|")
  body <- apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |"))
  c(header, divider, body)
}

build_routing_qa <- function(root, n = BII_ROUTING_QA_N, seed = BII_ROUTING_QA_SEED) {
  spec <- bii_spec(root)
  ids <- subtests_with_item_bank(root, spec)
  ids <- ids[vapply(
    ids,
    function(id) !is.null(BII_ROUTE_HANDLERS[[spec$subtests[[id]]$administration$route_type]]),
    logical(1)
  )]
  if (length(ids) == 0L) stop("Nessun subtest con route type implementato da controllare.")

  lines <- c(
    "# QA delle regole adattive",
    "",
    "> Report generato da `R/build/routing_qa.R`. Contiene diagnostiche di",
    "> routing su popolazione **simulata**: non sono norme, non sono dati",
    "> empirici e non descrivono la difficolta reale degli item.",
    "",
    "## Manifest di build",
    "",
    paste0("- data: ", format(Sys.Date())),
    paste0("- seed: ", seed),
    paste0("- n simulati per subtest: ", n),
    paste0("- versione spec: ", spec$battery$version),
    paste0("- hash spec: ", bii_spec_hash(root)),
    paste0("- commit: ", bii_git_sha(root)),
    paste0("- modello: logistico a soglie ordinate, slope ", BII_SIM_PARAMS$slope,
           ", passo soglie ", BII_SIM_PARAMS$threshold_step),
    ""
  )

  overall <- list()
  for (id in ids) {
    simulated <- simulate_subtest(id, n = n, seed = seed, root = root)
    summary_row <- summarise_subtest_simulation(simulated, root)
    overall[[id]] <- summary_row
    context <- load_item_bank(id, root, spec)
    lines <- c(
      lines,
      paste0("## ", id, " — ", context$spec$name),
      "",
      paste0(
        "Item nell'item bank: ", nrow(context$items), " su ",
        context$spec$n_scored_items, " previsti. Range grezzo 0–",
        context$spec$scoring$raw_max, "."
      ),
      "",
      md_table(routing_by_age_band(simulated, spec$battery)),
      "",
      paste0(
        "Scarto medio fra grezzo dopo routing e grezzo a somministrazione ",
        "completa: ", round(summary_row$mean_routing_bias, 3),
        " punti. E la perdita di informazione dovuta a basale e interruzione."
      ),
      ""
    )
  }

  compact <- do.call(rbind, overall)
  numeric_cols <- vapply(compact, is.numeric, logical(1))
  compact[numeric_cols] <- lapply(compact[numeric_cols], function(x) round(x, 3))
  lines <- c(lines, "## Riepilogo", "", md_table(compact), "")

  lines <- c(
    lines,
    "## Come leggere questi numeri",
    "",
    "- `inversion_rate` molto alto indica un punto di partenza troppo avanzato;",
    "- `ceiling_rate` vicino a 1 e atteso: quasi tutti incontrano tre errori",
    "  consecutivi prima dell'ultimo item;",
    "- `floor_rate` e `at_raw_max_rate` sopra qualche punto percentuale",
    "  indicano che la forma non copre gli estremi del range di eta;",
    "- `mean_routing_bias` negativo indica che la regola di interruzione taglia",
    "  punteggio che la persona avrebbe ottenuto;",
    "- `mean_routing_bias` positivo indica il contrario: il credito pieno",
    "  inferito sotto il basale regala piu punti di quanti la persona ne",
    "  avrebbe presi davvero. Succede soprattutto nelle forme corte con",
    "  finestra di basale di due item, dove il punto di partenza dei piu grandi",
    "  lascia sotto di se una frazione grande della forma. Entro un paio di",
    "  punti percentuali del range grezzo e il prezzo normale di non",
    "  somministrare gli item facili; oltre, conviene spostare il punto di",
    "  partenza piu in basso o allargare la finestra di basale.",
    "",
    "Se uno di questi indicatori e implausibile, la correzione va fatta nella",
    "spec o nell'item bank, non in questo report."
  )

  out_dir <- file.path(root, "norms_BII", "generated")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(out_dir, "routing_qa.md")
  writeLines(lines, path, useBytes = TRUE)
  path
}

if (sys.nframe() == 0L) {
  root <- bii_qa_root()
  source(file.path(root, "R", "simulation", "simulate_subtest.R"))
  message("[QA] ", build_routing_qa(root))
  message("[OK] Report di routing rigenerato. Output simulato, non norme.")
}
