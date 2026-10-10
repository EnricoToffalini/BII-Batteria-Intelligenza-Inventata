# Unicità della risposta negli item RR di induzione di regole.
#
# Gli esempi positivi e negativi devono escludere ogni regola semplice diversa
# da quella prevista che porterebbe a scegliere un distrattore. Il test prova
# tutte le regole formate da una o due condizioni elementari su forma,
# riempimento e posizione; se una di queste spiega tutti gli esempi e accetta
# un distrattore, l'item ha una seconda risposta difendibile. È il difetto
# trovato nel QA di RR-SC-06, RR-SC-16 e RR-SC-20 (packet N11).

source(file.path(root, "R", "items", "load_items.R"), local = TRUE)
rr <- load_item_bank("RR", root)
items <- rbind(rr$practice, rr$items)
items <- items[items$family == "rule_induction", ]
if (nrow(items) == 0L) stop("RR: nessun item rule_induction da verificare.")

symbol_shape <- c("●" = "C", "○" = "C", "■" = "S", "□" = "S", "▲" = "T", "△" = "T")
symbol_fill <- c("●" = "F", "○" = "E", "■" = "F", "□" = "E", "▲" = "F", "△" = "E")
symbol_pattern <- paste0("[", paste(names(symbol_shape), collapse = ""), "]+")

parse_group <- function(text) {
  chars <- strsplit(trimws(text), "")[[1]]
  if (!length(chars) || !all(chars %in% names(symbol_shape))) stop("RR: gruppo non interpretabile: ", text)
  list(shape = unname(symbol_shape[chars]), fill = unname(symbol_fill[chars]))
}

# Liste di gruppi nella consegna, nell'ordine: prima i positivi, poi i negativi.
example_lists <- function(prompt) {
  lists <- regmatches(prompt, gregexpr(paste0(symbol_pattern, "( / ", symbol_pattern, ")+"), prompt))[[1]]
  if (length(lists) != 2L) stop("RR: attesi esempi positivi e negativi in: ", prompt)
  lapply(strsplit(lists, " / ", fixed = TRUE), function(groups) lapply(groups, parse_group))
}

# Condizioni elementari per gruppi di lunghezza n.
atoms_for <- function(n) {
  atoms <- list()
  add <- function(label, f) atoms[[label]] <<- f
  for (i in seq_len(n)) {
    for (s in c("C", "S", "T")) {
      local({
        i <- i; s <- s
        add(sprintf("forma %d = %s", i, s), function(g) g$shape[i] == s)
        add(sprintf("forma %d != %s", i, s), function(g) g$shape[i] != s)
      })
    }
    for (f in c("F", "E")) {
      local({
        i <- i; f <- f
        add(sprintf("riempimento %d = %s", i, f), function(g) g$fill[i] == f)
      })
    }
  }
  for (i in seq_len(n - 1L)) for (j in (i + 1L):n) {
    local({
      i <- i; j <- j
      add(sprintf("stessa forma %d-%d", i, j), function(g) g$shape[i] == g$shape[j])
      add(sprintf("forma diversa %d-%d", i, j), function(g) g$shape[i] != g$shape[j])
      add(sprintf("stesso riempimento %d-%d", i, j), function(g) g$fill[i] == g$fill[j])
      add(sprintf("riempimento diverso %d-%d", i, j), function(g) g$fill[i] != g$fill[j])
    })
  }
  for (k in 0:n) local({
    k <- k
    add(sprintf("%d figure piene", k), function(g) sum(g$fill == "F") == k)
  })
  for (s in c("C", "S", "T")) local({
    s <- s
    add(sprintf("contiene forma %s", s), function(g) s %in% g$shape)
    add(sprintf("non contiene forma %s", s), function(g) !s %in% g$shape)
  })
  atoms
}

for (i in seq_len(nrow(items))) {
  item <- items[i, ]
  examples <- example_lists(item$prompt)
  positives <- examples[[1]]
  negatives <- examples[[2]]
  options <- lapply(unlist(item[c("option_a", "option_b", "option_c", "option_d")]), parse_group)
  key <- match(item$correct_answer, LETTERS[1:4])
  n <- length(positives[[1]]$shape)
  if (any(vapply(c(positives, negatives, options), function(g) length(g$shape) != n, logical(1)))) {
    stop(item$item_id, ": gruppi di lunghezza diversa.")
  }

  atoms <- atoms_for(n)
  truth <- vapply(atoms, function(a) vapply(c(positives, negatives, options), a, logical(1)),
                  logical(length(positives) + length(negatives) + 4L))
  if (is.null(dim(truth))) truth <- matrix(truth, nrow = 1L)
  pos <- seq_along(positives)
  neg <- length(positives) + seq_along(negatives)
  opt <- length(positives) + length(negatives) + 1:4

  combos <- c(as.list(seq_along(atoms)), utils::combn(seq_along(atoms), 2L, simplify = FALSE))
  for (combo in combos) {
    holds <- apply(truth[, combo, drop = FALSE], 1L, all)
    if (all(holds[pos]) && !any(holds[neg])) {
      accepted <- which(holds[opt])
      wrong <- setdiff(accepted, key)
      if (length(wrong)) {
        stop(item$item_id, ": la regola «", paste(names(atoms)[combo], collapse = " e "),
             "» spiega tutti gli esempi e accetta l'opzione ", LETTERS[wrong[1]], ".")
      }
    }
  }
}
