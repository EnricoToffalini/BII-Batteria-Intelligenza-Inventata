library(shiny)
library(tidyverse)
library(stringr)

# ============================================================
# BII – nomenclatura (UI: nomi estesi + abbreviazioni)
# Grafici: SOLO abbreviazioni
# Bande nei grafici: stessi colori dei box
# ============================================================

SUBTEST_INFO <- tibble::tribble(
  ~abbr, ~label,                                   ~max_raw,
  "SP",  "Significato delle Parole (SP)",          36,
  "RS",  "Relazioni Semantiche (RS)",              24,
  "CS",  "Conoscenza Sociale (CS)",                20,
  "MR",  "Matrici di Regole (MR)",                 24,
  "RR",  "Ragionamento per Regole (RR)",           20,
  "QS",  "Quantità e Strategie (QS)",              24,
  "MO",  "Mosaici (MO)",                           32,
  "RP",  "Rotazioni e Prospettive (RP)",           20,
  "MP",  "Mappe e Percorsi (MP)",                  20,
  "SM",  "Sequenze e Manipolazione (SM)",          24,
  "PG",  "Posizioni su Griglia (PG)",              16,
  "CL",  "Confronti Lampo (CL)",                   100,
  "SS",  "Scansione Selettiva (SS)",               100,
  "CR",  "Coppie da Ricordare (CR)",               20,
  "DM",  "Disegni in Memoria (DM)",                8
)

SUBTESTS_ALL <- SUBTEST_INFO$abbr

QI_TOTALE_TASKS <- c("SP","RS","MR","RR","MO","RP","SM","CL","CR")  # 9 core
QI_RAPIDO_TASKS <- c("SP","RS","MR","RR")                          # 4

INDICES_SPEC <- list(
  qIC = c("SP","RS"),
  qIF = c("MR","RR"),
  qVS = c("MO","RP"),
  qML = c("SM","PG"),
  qVE = c("CL","SS"),
  qAR = c("CR","DM"),
  QI_rapido = QI_RAPIDO_TASKS,
  QI_totale = QI_TOTALE_TASKS
)

INDEX_LABELS <- c(
  qIC = "qIC – Quoziente di Intelligenza Cristallizzata (Gc)",
  qIF = "qIF – Quoziente di Intelligenza Fluida (Gf)",
  qVS = "qVS – Quoziente Visuo-Spaziale (Gv)",
  qML = "qML – Quoziente di Memoria di Lavoro (Gwm)",
  qVE = "qVE – Quoziente di Velocità di Elaborazione (Gs)",
  qAR = "qAR – Quoziente di Apprendimento e Recupero (Glr)",
  QI_rapido = "QI rapido (4 subtest)",
  QI_totale = "QI totale (9 subtest)"
)

# Abbreviazioni per grafici indici (e radar)
INDEX_ABBR_PLOT <- c(
  qIC = "qIC",
  qIF = "qIF",
  qVS = "qVS",
  qML = "qML",
  qVE = "qVE",
  qAR = "qAR",
  QI_rapido = "QI rap",
  QI_totale = "QI tot"
)

# ============================================================
# Colori (coerenti: box + bande grafici)
# ============================================================

COLORS_LEVELS <- c(
  "Molto basso" = "#c2182b",
  "Basso"       = "#f6b53d",
  "Nella norma" = "#b5e5de",
  "Alto"        = "#47a767",
  "Molto alto"  = "#004c66",
  "Non calcolato" = "grey70"
)

# ============================================================
# NORME (assumo norms_BII/, fallback /mnt/data/)
# ============================================================

TASKS_TABLE_PATH_1    <- file.path("norms_BII", "tasks_conversion_tables_grezzo_to_PP_by_ageband_OFFICIAL.csv")
INDICES_TABLE_PATH_1  <- file.path("norms_BII", "indices_conversion_tables_sommaPP_to_SS_by_agegroup.csv")
TASKS_TABLE_PATH_2    <- file.path("/mnt/data", "tasks_conversion_tables_grezzo_to_PP_by_ageband_OFFICIAL.csv")
INDICES_TABLE_PATH_2  <- file.path("/mnt/data", "indices_conversion_tables_sommaPP_to_SS_by_agegroup.csv")

TASKS_TABLE_PATH   <- if (file.exists(TASKS_TABLE_PATH_1)) TASKS_TABLE_PATH_1 else TASKS_TABLE_PATH_2
INDICES_TABLE_PATH <- if (file.exists(INDICES_TABLE_PATH_1)) INDICES_TABLE_PATH_1 else INDICES_TABLE_PATH_2

stopifnot(file.exists(TASKS_TABLE_PATH), file.exists(INDICES_TABLE_PATH))

task_norms <- readr::read_csv(TASKS_TABLE_PATH, show_col_types = FALSE) %>%
  transmute(
    task = as.character(task),
    age_band = as.character(age_band),
    age_lo_m = as.integer(age_lo_m),
    age_hi_m = as.integer(age_hi_m),
    grezzo = as.integer(grezzo),
    PP = as.numeric(PP_official)
  )

indices_norms <- readr::read_csv(INDICES_TABLE_PATH, show_col_types = FALSE) %>%
  transmute(
    indice = as.character(indice),
    age_group = as.character(age_group),
    sommaPP = as.integer(sommaPP),
    SS = as.numeric(SS_100_15)
  )

AGE_MIN_M <- min(task_norms$age_lo_m, na.rm = TRUE)
AGE_MAX_M <- max(task_norms$age_hi_m, na.rm = TRUE)

# ============================================================
# Campione standardizzazione (per “pesca casuale”)
# ============================================================

STD_SAMPLE_PATH_1 <- file.path("norms_BII", "standardization_sample_raw.csv")
STD_SAMPLE_PATH_2 <- file.path("/mnt/data", "standardization_sample_raw.csv")
STD_SAMPLE_PATH <- if (file.exists(STD_SAMPLE_PATH_1)) STD_SAMPLE_PATH_1 else STD_SAMPLE_PATH_2

std_sample_raw <- if (file.exists(STD_SAMPLE_PATH)) {
  readr::read_csv(STD_SAMPLE_PATH, show_col_types = FALSE)
} else {
  NULL
}

# ============================================================
# Utility
# ============================================================

fmt_blank <- function(x) ifelse(is.na(x), "", as.character(x))

age_group_from_months <- function(age_m) {
  dplyr::case_when(
    age_m >= 72  & age_m < 120 ~ "6-10 anni",
    age_m >= 120 & age_m < 192 ~ "11-16 anni",
    age_m >= 192 & age_m <= 264 ~ "17-22 anni",
    TRUE ~ NA_character_
  )
}

age_band_from_months <- function(age_m, norms_tbl) {
  hit <- norms_tbl %>%
    distinct(age_band, age_lo_m, age_hi_m) %>%
    filter(age_lo_m <= age_m, age_hi_m >= age_m) %>%
    slice(1)
  if (nrow(hit) == 0) return(NA_character_)
  hit$age_band[[1]]
}

lookup_PP <- function(task, age_band, grezzo, norms_tbl) {
  if (is.na(grezzo) || is.na(age_band)) return(NA_real_)
  hit <- norms_tbl %>%
    filter(.data$task == !!task, .data$age_band == !!age_band, .data$grezzo == !!as.integer(grezzo)) %>%
    slice(1)
  if (nrow(hit) == 0) return(NA_real_)
  hit$PP[[1]]
}

lookup_SS <- function(indice, age_group, sommaPP, norms_tbl) {
  if (is.na(sommaPP) || is.na(age_group)) return(NA_real_)
  hit <- norms_tbl %>%
    filter(.data$indice == !!indice, .data$age_group == !!age_group, .data$sommaPP == !!as.integer(sommaPP)) %>%
    slice(1)
  if (nrow(hit) == 0) return(NA_real_)
  hit$SS[[1]]
}

make_radar_df <- function(labels, values) {
  df <- tibble(
    axis = factor(labels, levels = labels),
    value = as.numeric(values),
    miss = is.na(value)
  )
  df %>%
    mutate(seg = cumsum(miss | lag(miss, default = TRUE))) %>%
    filter(!miss)
}

class_ss <- function(ss) {
  if (is.na(ss)) return(list(label = "Indice non calcolato", color = COLORS_LEVELS[["Non calcolato"]]))
  if (ss < 70)   return(list(label = "Molto basso", color = COLORS_LEVELS[["Molto basso"]]))
  if (ss < 85)   return(list(label = "Basso",       color = COLORS_LEVELS[["Basso"]]))
  if (ss <= 115) return(list(label = "Nella norma", color = COLORS_LEVELS[["Nella norma"]]))
  if (ss < 130)  return(list(label = "Alto",        color = COLORS_LEVELS[["Alto"]]))
  list(label = "Molto alto", color = COLORS_LEVELS[["Molto alto"]])
}

# ============================================================
# UI
# ============================================================

ui <- fluidPage(
  titlePanel("BII – Profilo subtest e indici (simulato, didattico)"),
  sidebarLayout(
    sidebarPanel(
      h4("Età"),
      fluidRow(
        column(6, numericInput("age_y", "Anni", value = 10, min = AGE_MIN_M %/% 12, max = AGE_MAX_M %/% 12, step = 1)),
        column(6, numericInput("age_mo", "Mesi", value = 0, min = 0, max = 11, step = 1))
      ),
      tags$hr(),
      checkboxInput("prefer_rapido", "Preferisci QI rapido anche se QI totale è calcolabile", value = FALSE),
      tags$hr(),
      actionButton("random_subject", "Pesca 1 soggetto casuale (campione)"),
      tags$hr(),
      h4("Punteggi grezzi"),
      uiOutput("subtest_inputs"),
      tags$hr(),
      actionButton("compute", "Calcola")
    ),
    mainPanel(
      uiOutput("warnings"),
      tags$hr(),
      
      h3("Subtest (PP, M = 10, SD = 3)"),
      plotOutput("subtests_plot", height = 520),
      
      tags$hr(),
      fluidRow(
        column(8, h3("Indici e quozienti (SS, M = 100, SD = 15)")),
        column(4, checkboxInput("show_radar_indices", "Mostra come radar", value = FALSE))
      ),
      conditionalPanel(
        condition = "input.show_radar_indices == false",
        plotOutput("indices_plot", height = 520)
      ),
      conditionalPanel(
        condition = "input.show_radar_indices == true",
        plotOutput("indices_radar", height = 560)
      ),
      
      tags$hr(),
      h3("Riepilogo indici"),
      uiOutput("index_boxes"),
      
      tags$hr(),
      h3("Tabella punteggi"),
      tableOutput("scores_table")
    )
  )
)

# ============================================================
# SERVER
# ============================================================

server <- function(input, output, session) {
  
  recalc_trigger <- reactiveVal(0)
  
  output$subtest_inputs <- renderUI({
    tagList(lapply(seq_len(nrow(SUBTEST_INFO)), function(i) {
      ab <- SUBTEST_INFO$abbr[i]
      lab <- SUBTEST_INFO$label[i]
      mx <- SUBTEST_INFO$max_raw[i]
      selectInput(
        inputId = paste0("raw_", ab),
        label = lab,
        choices = c("no dato" = "", setNames(as.character(0:mx), as.character(0:mx))),
        selected = ""
      )
    }))
  })
  
  observeEvent(list(input$age_y, input$age_mo), {
    y <- suppressWarnings(as.integer(input$age_y))
    mo <- suppressWarnings(as.integer(input$age_mo))
    if (is.na(y)) y <- AGE_MIN_M %/% 12
    if (is.na(mo)) mo <- 0L
    
    y_min <- AGE_MIN_M %/% 12
    y_max <- AGE_MAX_M %/% 12
    
    y <- max(y_min, min(y_max, y))
    max_mo <- if (y == y_max) (AGE_MAX_M %% 12) else 11
    min_mo <- if (y == y_min) (AGE_MIN_M %% 12) else 0
    
    mo <- max(min_mo, min(max_mo, mo))
    
    if (!identical(y, as.integer(input$age_y))) updateNumericInput(session, "age_y", value = y)
    if (!identical(mo, as.integer(input$age_mo))) updateNumericInput(session, "age_mo", value = mo, min = min_mo, max = max_mo)
  }, ignoreInit = TRUE)
  
  observeEvent(input$random_subject, {
    if (is.null(std_sample_raw) || nrow(std_sample_raw) == 0) {
      showNotification("Campione di standardizzazione non disponibile (standardization_sample_raw.csv).", type = "error")
      return()
    }
    
    row <- std_sample_raw %>% slice_sample(n = 1)
    
    if ("age_y" %in% names(row)) {
      ay <- suppressWarnings(as.numeric(row$age_y[[1]]))
      if (is.finite(ay)) {
        
        yy <- floor(ay)
        mm <- round((ay - yy) * 12)
        
        if (mm >= 12) { yy <- yy + 1; mm <- 0 }
        if (mm < 0)   { mm <- 0 }
        
        y_min <- AGE_MIN_M %/% 12
        y_max <- AGE_MAX_M %/% 12
        
        yy <- max(y_min, min(y_max, yy))
        max_mo <- if (yy == y_max) (AGE_MAX_M %% 12) else 11
        min_mo <- if (yy == y_min) (AGE_MIN_M %% 12) else 0
        
        mm <- max(min_mo, min(max_mo, mm))
        
        updateNumericInput(session, "age_y", value = yy)
        updateNumericInput(session, "age_mo", value = mm, min = min_mo, max = max_mo)
      }
    }
    
    for (ab in SUBTESTS_ALL) {
      col <- paste0(ab, "_grezzo")
      if (col %in% names(row)) {
        vv <- row[[col]][[1]]
        if (is.na(vv)) {
          updateSelectInput(session, paste0("raw_", ab), selected = "")
        } else {
          updateSelectInput(session, paste0("raw_", ab), selected = as.character(as.integer(vv)))
        }
      } else {
        updateSelectInput(session, paste0("raw_", ab), selected = "")
      }
    }
    
    recalc_trigger(recalc_trigger() + 1)
  })
  
  results <- eventReactive(list(input$compute, recalc_trigger()), {
    y <- suppressWarnings(as.integer(isolate(input$age_y)))
    mo <- suppressWarnings(as.integer(isolate(input$age_mo)))
    if (is.na(y) || is.na(mo)) return(list(ok = FALSE, msgs = c("Età non valida.")))
    
    age_m <- y * 12 + mo
    if (age_m < AGE_MIN_M || age_m > AGE_MAX_M) return(list(ok = FALSE, msgs = c("Età fuori range norme.")))
    
    age_band <- age_band_from_months(age_m, task_norms)
    age_group <- age_group_from_months(age_m)
    
    raw <- setNames(rep(NA_real_, nrow(SUBTEST_INFO)), SUBTEST_INFO$abbr)
    for (ab in SUBTEST_INFO$abbr) {
      vv <- isolate(input[[paste0("raw_", ab)]])
      raw[[ab]] <- suppressWarnings(ifelse(vv == "" || is.null(vv), NA_real_, as.numeric(vv)))
    }
    
    PP <- setNames(rep(NA_real_, length(raw)), names(raw))
    for (ab in names(raw)) {
      PP[[ab]] <- lookup_PP(task = ab, age_band = age_band, grezzo = raw[[ab]], norms_tbl = task_norms)
    }
    
    prefer_rapido <- isTRUE(isolate(input$prefer_rapido))
    have_totale <- all(!is.na(PP[QI_TOTALE_TASKS]))
    have_rapido <- all(!is.na(PP[QI_RAPIDO_TASKS]))
    
    compute_totale <- have_totale && !prefer_rapido
    compute_rapido <- if (prefer_rapido) have_rapido else (!have_totale && have_rapido)
    
    sumpp_totale <- if (compute_totale) sum(PP[QI_TOTALE_TASKS]) else NA_real_
    ss_totale <- if (compute_totale) lookup_SS("QI_totale", age_group, sumpp_totale, indices_norms) else NA_real_
    
    sumpp_rapido <- if (compute_rapido) sum(PP[QI_RAPIDO_TASKS]) else NA_real_
    ss_rapido <- if (compute_rapido) lookup_SS("QI_rapido", age_group, sumpp_rapido, indices_norms) else NA_real_
    
    ind_sumpp <- list(); ind_ss <- list()
    for (nm in c("qIC","qIF","qVS","qML","qVE","qAR")) {
      req_tasks <- INDICES_SPEC[[nm]]
      ok <- all(!is.na(PP[req_tasks]))
      ind_sumpp[[nm]] <- if (ok) sum(PP[req_tasks]) else NA_real_
      ind_ss[[nm]] <- if (ok) lookup_SS(nm, age_group, ind_sumpp[[nm]], indices_norms) else NA_real_
    }
    
    msgs <- character(0)
    if (is.na(age_band) || is.na(age_group)) msgs <- c(msgs, "Età non classificabile (banda/gruppo).")
    if (!have_totale && !have_rapido) msgs <- c(msgs, "QI non calcolabile: mancano PP necessari per QI totale e QI rapido.")
    if (have_totale && prefer_rapido && !have_rapido) msgs <- c(msgs, "Preferenza QI rapido attiva, ma QI rapido non è calcolabile, nessun QI riportato.")
    
    list(
      ok = TRUE, msgs = msgs,
      age_m = age_m, age_band = age_band, age_group = age_group,
      raw = raw, PP = PP,
      compute_totale = compute_totale, compute_rapido = compute_rapido,
      sumpp_totale = sumpp_totale, ss_totale = ss_totale,
      sumpp_rapido = sumpp_rapido, ss_rapido = ss_rapido,
      ind_sumpp = ind_sumpp, ind_ss = ind_ss
    )
  })
  
  output$warnings <- renderUI({
    res <- results()
    if (!is.list(res)) return(NULL)
    if (!isTRUE(res$ok)) return(div(style="color:#b2182b;", HTML("&#9888; Errore di input.")))
    if (length(res$msgs) == 0) return(NULL)
    div(lapply(res$msgs, function(m) div(style="color:#b2182b;", HTML(paste0("&#9888; ", m)))))
  })
  
  # ============================================================
  # SUBTEST plot – bande con colori dei box
  # ============================================================
  output$subtests_plot <- renderPlot({
    res <- results(); req(isTRUE(res$ok))
    
    df <- tibble(
      abbr = factor(SUBTEST_INFO$abbr, levels = SUBTEST_INFO$abbr),
      PP = as.numeric(res$PP[SUBTEST_INFO$abbr])
    )
    
    bands <- tibble::tribble(
      ~ymin, ~ymax, ~band,
      1,     3.5,   "Molto basso",
      3.5,   6.5,   "Basso",
      6.5,   13.5,  "Nella norma",
      13.5,  16.5,  "Alto",
      16.5,  19,    "Molto alto"
    )
    
    ggplot() +
      geom_rect(data = bands,
                aes(xmin = -Inf, xmax = Inf, ymin = ymin, ymax = ymax, fill = band),
                alpha = 0.18, inherit.aes = FALSE) +
      scale_fill_manual(values = COLORS_LEVELS) +
      geom_hline(yintercept = c(3.5, 6.5, 13.5, 16.5), linewidth = 0.3, alpha = 0.35) +
      geom_point(data = df %>% filter(!is.na(PP)), aes(x = abbr, y = PP), size = 3) +
      geom_line(data = df %>% filter(!is.na(PP)), aes(x = abbr, y = PP, group = 1), linewidth = 0.6, alpha = 0.7) +
      scale_y_continuous(limits = c(1, 19), breaks = 1:19) +
      labs(x = NULL, y = "Punteggio ponderato (PP)") +
      guides(fill = "none") +
      theme_minimal(base_size = 14) +
      theme(panel.grid.major.x = element_blank())
  })
  
  # ============================================================
  # INDICI plot – bande con colori dei box
  # ============================================================
  output$indices_plot <- renderPlot({
    res <- results(); req(isTRUE(res$ok))
    
    idx_names <- c(
      if (isTRUE(res$compute_totale)) "QI_totale" else if (isTRUE(res$compute_rapido)) "QI_rapido" else NA_character_,
      "qIC","qIF","qVS","qML","qVE","qAR"
    )
    idx_names <- idx_names[!is.na(idx_names)]
    
    SS_vals <- sapply(idx_names, function(nm) {
      if (nm == "QI_totale") return(res$ss_totale)
      if (nm == "QI_rapido") return(res$ss_rapido)
      res$ind_ss[[nm]]
    })
    
    df <- tibble(
      abbr = factor(unname(INDEX_ABBR_PLOT[idx_names]), levels = unname(INDEX_ABBR_PLOT[idx_names])),
      SS = as.numeric(SS_vals)
    )
    
    bands <- tibble::tribble(
      ~ymin, ~ymax, ~band,
      40,  70,  "Molto basso",
      70,  85,  "Basso",
      85,  115, "Nella norma",
      115, 130, "Alto",
      130, 160, "Molto alto"
    )
    
    ggplot() +
      geom_rect(data = bands,
                aes(xmin = -Inf, xmax = Inf, ymin = ymin, ymax = ymax, fill = band),
                alpha = 0.18, inherit.aes = FALSE) +
      scale_fill_manual(values = COLORS_LEVELS) +
      geom_hline(yintercept = c(70, 85, 115, 130), linewidth = 0.3, alpha = 0.35) +
      geom_hline(yintercept = 100, linewidth = 0.4, alpha = 0.5) +
      geom_point(data = df %>% filter(!is.na(SS)), aes(x = abbr, y = SS), size = 3) +
      geom_line(data = df %>% filter(!is.na(SS)), aes(x = abbr, y = SS, group = 1), linewidth = 0.6, alpha = 0.7) +
      scale_y_continuous(limits = c(40, 160), breaks = c(40, 55, 70, 85, 100, 115, 130, 145, 160)) +
      labs(x = NULL, y = "Punteggio standardizzato (SS)") +
      guides(fill = "none") +
      theme_minimal(base_size = 14) +
      theme(panel.grid.major.x = element_blank())
  })
  
  # ============================================================
  # INDICI radar – etichette: abbreviazioni
  # ============================================================
  output$indices_radar <- renderPlot({
    res <- results(); req(isTRUE(res$ok))
    
    idx_names <- c(
      if (isTRUE(res$compute_totale)) "QI_totale" else if (isTRUE(res$compute_rapido)) "QI_rapido" else NA_character_,
      "qIC","qIF","qVS","qML","qVE","qAR"
    )
    idx_names <- idx_names[!is.na(idx_names)]
    
    labs <- unname(INDEX_ABBR_PLOT[idx_names])
    vals <- sapply(idx_names, function(nm) {
      if (nm == "QI_totale") return(res$ss_totale)
      if (nm == "QI_rapido") return(res$ss_rapido)
      res$ind_ss[[nm]]
    })
    
    df_path <- make_radar_df(labels = labs, values = vals)
    
    grid_r <- c(70, 85, 100, 115, 130)
    grid_df <- tidyr::expand_grid(axis = factor(labs, levels = labs), r = grid_r) %>%
      arrange(r, axis)
    
    ggplot() +
      geom_path(data = grid_df, aes(x = axis, y = r, group = r), linewidth = 0.4, alpha = 0.35) +
      geom_point(data = df_path, aes(x = axis, y = value), size = 2.7) +
      geom_path(data = df_path, aes(x = axis, y = value, group = seg), linewidth = 0.9) +
      coord_polar(start = -pi/2, clip = "off") +
      scale_y_continuous(limits = c(40, 160), breaks = grid_r) +
      labs(x = NULL, y = NULL) +
      theme_minimal(base_size = 13) +
      theme(
        panel.grid = element_blank(),
        axis.text.x = element_text(size = 11),
        plot.margin = margin(20, 60, 20, 60)
      )
  })
  
  # ============================================================
  # BOX INDICI (sotto grafici, sopra tabella)
  # ============================================================
  output$index_boxes <- renderUI({
    res <- results(); req(isTRUE(res$ok))
    
    idx_names <- c(
      if (isTRUE(res$compute_totale)) "QI_totale" else if (isTRUE(res$compute_rapido)) "QI_rapido" else NA_character_,
      "qIC","qIF","qVS","qML","qVE","qAR"
    )
    idx_names <- idx_names[!is.na(idx_names)]
    
    get_ss <- function(nm) {
      if (nm == "QI_totale") return(res$ss_totale)
      if (nm == "QI_rapido") return(res$ss_rapido)
      res$ind_ss[[nm]]
    }
    
    tagList(lapply(idx_names, function(nm) {
      ss <- suppressWarnings(as.numeric(get_ss(nm)))
      rk <- class_ss(ss)
      
      div(
        style = sprintf(
          "border-left:6px solid %s; padding:12px; background:#fafafa; margin-bottom:10px;",
          rk$color
        ),
        h4(HTML(sprintf("%s", INDEX_LABELS[[nm]]))),
        h3(HTML(sprintf("SS: <b>%s</b>", ifelse(is.na(ss), "—", as.integer(round(ss)))))),
        p(HTML(sprintf("Interpretazione: <b style='color:%s'>%s</b>", rk$color, rk$label))),
        if (is.na(ss)) {
          p(HTML("<small>Calcolato solo se sono presenti i PP necessari (tutti i subtest richiesti per quell’indice).</small>"))
        } else {
          NULL
        }
      )
    }))
  })
  
  # ============================================================
  # TABELLA – mai "NA", label estese
  # ============================================================
  output$scores_table <- renderTable({
    res <- results(); req(isTRUE(res$ok))
    
    df_sub <- tibble(
      Voce = SUBTEST_INFO$label,
      `Grezzo` = as.numeric(res$raw[SUBTEST_INFO$abbr]),
      `Ponderato` = as.numeric(res$PP[SUBTEST_INFO$abbr]),
      `Standardizzato (indice)` = NA_real_
    )
    
    df_qi <- tibble()
    if (isTRUE(res$compute_totale)) {
      df_qi <- tibble(
        Voce = INDEX_LABELS[["QI_totale"]],
        `Grezzo` = NA_real_,
        `Ponderato` = res$sumpp_totale,
        `Standardizzato (indice)` = res$ss_totale
      )
    } else if (isTRUE(res$compute_rapido)) {
      df_qi <- tibble(
        Voce = INDEX_LABELS[["QI_rapido"]],
        `Grezzo` = NA_real_,
        `Ponderato` = res$sumpp_rapido,
        `Standardizzato (indice)` = res$ss_rapido
      )
    }
    
    df_idx <- tibble(
      Voce = unname(INDEX_LABELS[c("qIC","qIF","qVS","qML","qVE","qAR")]),
      `Grezzo` = NA_real_,
      `Ponderato` = as.numeric(unlist(res$ind_sumpp[c("qIC","qIF","qVS","qML","qVE","qAR")])),
      `Standardizzato (indice)` = as.numeric(unlist(res$ind_ss[c("qIC","qIF","qVS","qML","qVE","qAR")]))
    )
    
    out <- bind_rows(df_sub, df_qi, df_idx) %>%
      mutate(
        `Grezzo` = fmt_blank(`Grezzo`),
        `Ponderato` = fmt_blank(`Ponderato`),
        `Standardizzato (indice)` = fmt_blank(`Standardizzato (indice)`)
      )
    
    out
  }, striped = TRUE, bordered = TRUE, spacing = "s")
}

shinyApp(ui, server)
