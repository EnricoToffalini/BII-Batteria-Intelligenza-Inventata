source(file.path(root, "R", "scoring", "administer.R"), local = TRUE)

cr <- load_item_bank("CR", root)
items <- cr$items
stopifnot(nrow(items) == 14L, nrow(cr$practice) == 0L)

# --- struttura: insieme fisso, nessuna regola adattiva -------------------------

stopifnot(
  identical(cr$spec$administration$route_type, "delayed_retrieval"),
  identical(cr$spec$item_ordering, "fixed_set"),
  is.null(cr$spec$administration$basal),
  is.null(cr$spec$administration$ceiling)
)

# Tutti gli item vengono somministrati a tutti, a qualunque eta.
for (age in c(72L, 140L, 263L)) {
  routed <- route_subtest("CR", rep(2, nrow(items)), age_months = age, root = root)
  stopifnot(
    all(routed$administration_status == "administered"),
    sum(routed$assigned_score) == cr$spec$scoring$raw_max,
    !isTRUE(attr(routed, "inversion_applied"))
  )
}
# Un'eta fuori range resta un errore anche senza routing per eta.
stopifnot(inherits(try(route_subtest("CR", rep(2, nrow(items)), 60, root = root), silent = TRUE), "try-error"))

# --- qualita dell'insieme di coppie -------------------------------------------

# Coppie arbitrarie: nessuna parola serve sia da cue sia da bersaglio, e non
# esistono cue o bersagli ripetuti.
stopifnot(
  !anyDuplicated(items$cue),
  !anyDuplicated(items$target),
  length(intersect(items$cue, items$target)) == 0L,
  all(items$scoring_key == items$target)
)

# Ogni item di riconoscimento deve contenere due bersagli di ALTRE coppie: e
# quello che impedisce di prendere un punto riconoscendo la sola parola
# "gia sentita" senza ricordare l'associazione.
option_columns <- c("option_a", "option_b", "option_c", "option_d")
for (i in seq_len(nrow(items))) {
  options <- unlist(items[i, option_columns], use.names = FALSE)
  other_targets <- setdiff(items$target, items$target[i])
  if (sum(options %in% other_targets) < 2L) {
    stop(items$item_id[i], ": il riconoscimento ha meno di due bersagli di altre coppie.")
  }
  if (!items$target[i] %in% options) stop(items$item_id[i], ": bersaglio assente fra le opzioni.")
}

# --- punteggio derivato dalle componenti --------------------------------------

base_record <- data.frame(
  item_id = items$item_id,
  administration_status = "administered",
  recall = "correct",
  recognition = "not_administered",
  delay_minutes = 15,
  stringsAsFactors = FALSE
)

# Tutto recuperato: 2 punti per item.
perfect <- score_subtest_record("CR", base_record, root)
stopifnot(
  perfect$valid,
  perfect$raw_score == cr$spec$scoring$raw_max,
  perfect$raw_score == 2 * nrow(items),
  length(perfect$warnings) == 0L
)

# Recupero fallito ma riconoscimento corretto: 1 punto. Recupero fallito e
# riconoscimento sbagliato: 0. Calcolato a mano: 10 item da 2, 2 da 1, 2 da 0.
mixed <- base_record
mixed$recall[11:12] <- "incorrect"
mixed$recognition[11:12] <- "correct"
mixed$recall[13:14] <- "omitted"
mixed$recognition[13:14] <- "incorrect"
scored <- score_subtest_record("CR", mixed, root)
stopifnot(
  scored$valid,
  scored$raw_score == 10 * 2 + 2 * 1 + 2 * 0,
  identical(scored$items$assigned_score, c(rep(2, 10), 1, 1, 0, 0))
)

# Un'omissione con riconoscimento corretto vale 1 come un errore: la scala
# riguarda la traccia recuperabile, non il tipo di fallimento del richiamo.
omitted_then_recognised <- base_record
omitted_then_recognised$recall[1] <- "omitted"
omitted_then_recognised$recognition[1] <- "correct"
stopifnot(score_subtest_record("CR", omitted_then_recognised, root)$raw_score == 2 * nrow(items) - 1)

# --- il record incompleto non diventa uno zero --------------------------------

incomplete <- base_record
incomplete$recall[3] <- "incorrect"
# recognition resta not_administered: l'item non e calcolabile
attempt <- try(score_subtest_record("CR", incomplete, root), silent = TRUE)
stopifnot(
  inherits(attempt, "try-error"),
  grepl("CR-SC-03", conditionMessage(attr(attempt, "condition"))),
  grepl("non viene inventato", conditionMessage(attr(attempt, "condition")))
)

# Un valore di componente non previsto dalla spec viene rifiutato.
bad_component <- base_record
bad_component$recall[1] <- "quasi"
stopifnot(inherits(try(score_subtest_record("CR", bad_component, root), silent = TRUE), "try-error"))

# --- il ritardo effettivo e un dato procedurale, non un punteggio -------------

late <- base_record
late$delay_minutes <- 25
late_scored <- score_subtest_record("CR", late, root)
stopifnot(
  late_scored$valid,
  late_scored$raw_score == 2 * nrow(items),
  any(grepl("fuori dalla finestra", late_scored$warnings))
)

no_delay <- base_record
no_delay$delay_minutes <- NA
stopifnot(any(grepl("non registrato", score_subtest_record("CR", no_delay, root)$warnings)))

# Gli stati esterni restano non convertibili in errori.
external <- base_record
external$administration_status[4] <- "external_missing"
external$recall[4] <- NA
external$recognition[4] <- NA
external_scored <- score_subtest_record("CR", external, root)
stopifnot(!external_scored$valid, is.na(external_scored$raw_score))

# --- modulo di registrazione --------------------------------------------------

form <- utils::read.csv(
  file.path(root, "materials", "record_forms", "CR_record_form.csv"),
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(
  identical(form$item_id, items$item_id),
  # il punteggio e derivato: chiederlo nel modulo invoglierebbe a scriverlo
  !"item_score" %in% names(form),
  all(c("recall", "recognition", "delay_minutes") %in% names(form))
)
