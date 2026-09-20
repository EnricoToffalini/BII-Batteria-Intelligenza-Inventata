source(file.path(root, "R", "simulation", "simulate_SP.R"), local = TRUE)

first <- simulate_sp(n = 400, seed = 42, root = root)
second <- simulate_sp(n = 400, seed = 42, root = root)
sp_context <- load_item_bank("SP", root)
sp_raw_max <- sp_context$spec$scoring$raw_max
stopifnot(
  identical(first, second),
  all(first$data_source == "simulated"),
  all(first$raw_score >= 0 & first$raw_score <= sp_raw_max),
  all(first$n_administered >= 3 & first$n_administered <= nrow(sp_context$items)),
  any(first$inversion_applied),
  any(first$ceiling_reached)
)

# Controllo volutamente ampio: verifica la direzione del modello generativo,
# non cerca di ottenere statistiche particolarmente belle.
simulation_summary <- summarise_sp_simulation(first, root)
stopifnot(
  simulation_summary$mean_raw_older > simulation_summary$mean_raw_younger,
  simulation_summary$subtest == "SP",
  simulation_summary$n == 400
)
