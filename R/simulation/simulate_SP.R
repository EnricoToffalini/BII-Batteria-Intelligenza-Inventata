# Scorciatoia SP sulla simulazione item-level generica.
# Il modello generativo e le diagnostiche stanno in simulate_subtest.R.

if (!exists("simulate_subtest", mode = "function")) {
  .bii_sp_sim_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(.bii_sp_sim_root, "R", "simulation", "simulate_subtest.R"))) break
    .bii_sp_sim_parent <- dirname(.bii_sp_sim_root)
    if (identical(.bii_sp_sim_parent, .bii_sp_sim_root)) stop("Repository BII non trovato.", call. = FALSE)
    .bii_sp_sim_root <- .bii_sp_sim_parent
  }
  source(file.path(.bii_sp_sim_root, "R", "simulation", "simulate_subtest.R"), local = TRUE)
}

simulate_sp <- function(n = 500L, seed = 20260910L, root = NULL) {
  simulate_subtest("SP", n = n, seed = seed, root = root)
}

summarise_sp_simulation <- function(x, root = NULL) {
  summarise_subtest_simulation(x, root)
}

if (sys.nframe() == 0L) {
  simulated <- simulate_sp()
  print(summarise_sp_simulation(simulated), row.names = FALSE)
  message("Output simulato: controllo tecnico, non norme empiriche.")
}
