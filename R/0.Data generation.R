############################################################
# BII - Simulazione generativa completa (15 subtest)
# - dat_lat: latenti (per controlli e didattica)
# - dat_obs: SOLO osservate (eta + punteggi grezzi + componenti tempo/riconoscimento)
# - base R per simulazione, ggplot2 per visualizzazione
############################################################

set.seed(0)
library(ggplot2)
theme_set(theme_bw(base_size = 14))

########################
# 0) Parametri generali
########################
N <- 1600
age_min_y <- 6
age_max_y <- 21

# eta in mesi
age_y_int <- sample(age_min_y:age_max_y, N, replace = TRUE)
age_m_offset <- sample(0:11, N, replace = TRUE)
age_m <- age_y_int * 12 + age_m_offset
age_y <- age_m / 12

# A: indice di sviluppo 0..~1 senza schiacciamenti, poi A_cap per il plateau nel generatore
age_cap <- 19.5
A <- log(age_y - 5) / log(age_cap - 5)
A <- pmax(0, A)
A_cap <- pmin(1, A)

#############################################
# 1) Fattori latenti (g + CHC)
#############################################
# g: crescita forte + varianza che diminuisce (compressione in adulto)
b_g <- 4
mu_g <- b_g * A_cap

sd_g_6  <- 1
sd_g_22 <- 0.6
sd_g <- sd_g_6 + (sd_g_22 - sd_g_6) * A_cap

g <- rnorm(N, mean = mu_g, sd = sd_g)

# specifici: crescono ma meno di g, Gv reso più evidente
mu_Gc  <- 2.2 * A_cap
mu_Gf  <- 2.2 * A_cap
mu_Gv  <- 2.0 * A_cap 
mu_Gwm <- 1.8 * A_cap
mu_Gs  <- 2.2 * A_cap
mu_Glr <- 2.0 * A_cap

sd_spec <- 0.9

Gc  <- rnorm(N, mu_Gc,  sd_spec)
Gf  <- rnorm(N, mu_Gf,  sd_spec)
Gv  <- rnorm(N, mu_Gv,  sd_spec)
Gwm <- rnorm(N, mu_Gwm, sd_spec)
Gs  <- rnorm(N, mu_Gs,  sd_spec)
Glr <- rnorm(N, mu_Glr, sd_spec)

#############################################
# 2) Subtest latenti (bifactor: g + specifico)
#############################################
# 15 subtest: SP RS CS MR RR QS MO RP MP SM PG CL SS CR DM
# mapping specifici:
# Gc:  SP RS CS
# Gf:  MR RR QS
# Gv:  MO RP MP
# Gwm: SM PG
# Gs:  CL SS
# Glr: CR DM

subtests <- c("SP","RS","CS","MR","RR","QS","MO","RP","MP","SM","PG","CL","SS","CR","DM")

# Loadings su g (core più alti, completion/supp leggermente più bassi)
lam_g <- c(
  SP=.82, RS=.78, CS=.68,
  MR=.80, RR=.76, QS=.66,
  MO=.72, RP=.70, MP=.65,
  SM=.68, PG=.64,
  CL=.66, SS=.62,
  CR=.70, DM=.62
)

# Loadings specifici (presenti ma modesti, un filo più alti nei supplementari di “approfondimento”)
lam_s <- c(
  SP=.32, RS=.28, CS=.35,
  MR=.30, RR=.28, QS=.36,
  MO=.35, RP=.33, MP=.38,
  SM=.30, PG=.34,
  CL=.40, SS=.42,
  CR=.34, DM=.40
)

# Residui: tarabili (più alti = subtest meno affidabile)
eps_sd <- c(
  SP=0.9, RS=0.9, CS=1,
  MR=0.9, RR=1, QS=1,
  MO=1, RP=0.8, MP=0.9,
  SM=1, PG=1.2,
  CL=1.1, SS=1.1,
  CR=1.3, DM=1.2
) * 0.4

# funzione helper per creare abilità subtest latente
make_theta <- function(name){
  if(name %in% c("SP","RS","CS"))  return(lam_g[name]*g + lam_s[name]*Gc  + rnorm(N,0,eps_sd[name]))
  if(name %in% c("MR","RR","QS"))  return(lam_g[name]*g + lam_s[name]*Gf  + rnorm(N,0,eps_sd[name]))
  if(name %in% c("MO","RP","MP"))  return(lam_g[name]*g + lam_s[name]*Gv  + rnorm(N,0,eps_sd[name]))
  if(name %in% c("SM","PG"))       return(lam_g[name]*g + lam_s[name]*Gwm + rnorm(N,0,eps_sd[name]))
  if(name %in% c("CL","SS"))       return(lam_g[name]*g + lam_s[name]*Gs  + rnorm(N,0,eps_sd[name]))
  if(name %in% c("CR","DM"))       return(lam_g[name]*g + lam_s[name]*Glr + rnorm(N,0,eps_sd[name]))
  stop("subtest non riconosciuto")
}

theta_list <- lapply(subtests, make_theta)
names(theta_list) <- paste0(subtests, "_lat")

#############################################
# 3) Da latenti a punteggi grezzi (osservati)
#############################################
# Subtest con range fisso 0..k: uso Binom(k, plogis(alpha + beta*theta))
sim_binom <- function(theta, k, alpha, beta){
  p <- plogis(alpha + beta*theta)
  rbinom(length(theta), size = k, prob = p)
}

# Range grezzi dal documento BII
# (per 0-1-2 tratto come punti totali 0..2*n, quindi Binom(2*n, p))
k_fixed <- c(
  SP=36, RS=24, CS=20,
  MR=24, RR=20, QS=24,
  MO=32, RP=20, MP=20,
  SM=24, PG=16,
  CR=20
)

# Parametri alpha/beta subtest (tweak-friendly)

delta_alpha = -1.7

par_ab <- list(
  SP=c(alpha = 0, beta=0.7),
  RS=c(alpha = -0.2, beta=0.8),
  CS=c(alpha = -0.3, beta=0.8),
  
  MR=c(alpha = -0.2, beta=0.8),
  RR=c(alpha = -0.1, beta=0.8),
  QS=c(alpha = -0.3, beta=0.8),
  
  MO=c(alpha = -0.1, beta=0.8),
  RP=c(alpha = -0.1, beta=0.7),
  MP=c(alpha = +0.1, beta=0.8),
  
  SM=c(alpha = -0.2, beta=0.9),
  PG=c(alpha = -0.1, beta=0.9),
  
  CR=c(alpha = -0.2, beta=0.9)
)
par_ab <- lapply(par_ab, function(v){
  v["alpha"] <- v["alpha"] + delta_alpha
  v
})


# Genero i grezzi a range fisso
SP <- sim_binom(theta_list[["SP_lat"]], k_fixed["SP"], par_ab$SP["alpha"], par_ab$SP["beta"])
RS <- sim_binom(theta_list[["RS_lat"]], k_fixed["RS"], par_ab$RS["alpha"], par_ab$RS["beta"])
CS <- sim_binom(theta_list[["CS_lat"]], k_fixed["CS"], par_ab$CS["alpha"], par_ab$CS["beta"])

MR <- sim_binom(theta_list[["MR_lat"]], k_fixed["MR"], par_ab$MR["alpha"], par_ab$MR["beta"])
RR <- sim_binom(theta_list[["RR_lat"]], k_fixed["RR"], par_ab$RR["alpha"], par_ab$RR["beta"])
QS <- sim_binom(theta_list[["QS_lat"]], k_fixed["QS"], par_ab$QS["alpha"], par_ab$QS["beta"])

MO <- sim_binom(theta_list[["MO_lat"]], k_fixed["MO"], par_ab$MO["alpha"], par_ab$MO["beta"])
RP <- sim_binom(theta_list[["RP_lat"]], k_fixed["RP"], par_ab$RP["alpha"], par_ab$RP["beta"])
MP <- sim_binom(theta_list[["MP_lat"]], k_fixed["MP"], par_ab$MP["alpha"], par_ab$MP["beta"])

SM <- sim_binom(theta_list[["SM_lat"]], k_fixed["SM"], par_ab$SM["alpha"], par_ab$SM["beta"])
PG <- sim_binom(theta_list[["PG_lat"]], k_fixed["PG"], par_ab$PG["alpha"], par_ab$PG["beta"])

CR <- sim_binom(theta_list[["CR_lat"]], k_fixed["CR"], par_ab$CR["alpha"], par_ab$CR["beta"])

# --- Subtest a tempo fisso / conteggi differenza (CL, SS) e riconoscimento (DM) ---
# CL: corretti, errori, omissioni, score = corretti - errori
CL_total <- 100
CL_theta <- theta_list[["CL_lat"]]

CL_attempt <- round(20 + (CL_total - 20) * plogis(-0.3 + 0.8*CL_theta))
CL_attempt <- pmin(CL_total, pmax(10, CL_attempt))

CL_p_correct <- plogis(-0.9 + 0.7*CL_theta)
CL_correct <- rbinom(N, size = CL_attempt, prob = CL_p_correct)
CL_not_correct <- CL_attempt - CL_correct
CL_p_error_given_not <- plogis(-1.6 - 0.4*CL_theta)
CL_error <- rbinom(N, size = CL_not_correct, prob = CL_p_error_given_not)
CL_omiss <- (CL_total - CL_attempt) + (CL_not_correct - CL_error)
CL <- CL_correct - CL_error
CL[CL < 0] <- 0

# SS: targets e distractors fissi, score = hit - false alarms
SS_theta <- theta_list[["SS_lat"]]
SS_targets <- 100
SS_distr  <- 100

SS_p_hit <- plogis(-1.7 + 0.9*SS_theta)
SS_p_fa  <- plogis(-3.5 - 0.2*SS_theta)  # fa diminuiscono all'aumentare di theta

SS_hit <- rbinom(N, size = SS_targets, prob = SS_p_hit)
SS_fa  <- rbinom(N, size = SS_distr,  prob = SS_p_fa)
SS_omiss <- SS_targets - SS_hit
SS <- SS_hit - SS_fa             # range teorico -100..+100
SS[SS < 0] <- 0

# DM: hit 0..8, fa 0..8, score = hit - fa (range -8..+8)
DM_theta <- theta_list[["DM_lat"]]
DM_targets <- 8
DM_distr  <- 8

DM_p_hit <- plogis(-1.5 + 0.9*DM_theta)
DM_p_fa  <- plogis(-3.5 - 0.3*DM_theta)

DM_hit <- rbinom(N, size = DM_targets, prob = DM_p_hit)
DM_fa  <- rbinom(N, size = DM_distr,  prob = DM_p_fa)
DM <- DM_hit - DM_fa
DM[DM < 0] = 0

#############################################
# 4) Dataset latente (per controlli) e osservato (solo grezzi)
#############################################
dat_lat <- data.frame(
  id=1:N, age_m=age_m, age_y=age_y, A=A, A_cap=A_cap,
  g=g, Gc=Gc, Gf=Gf, Gv=Gv, Gwm=Gwm, Gs=Gs, Glr=Glr,
  SP_lat=theta_list[["SP_lat"]], RS_lat=theta_list[["RS_lat"]], CS_lat=theta_list[["CS_lat"]],
  MR_lat=theta_list[["MR_lat"]], RR_lat=theta_list[["RR_lat"]], QS_lat=theta_list[["QS_lat"]],
  MO_lat=theta_list[["MO_lat"]], RP_lat=theta_list[["RP_lat"]], MP_lat=theta_list[["MP_lat"]],
  SM_lat=theta_list[["SM_lat"]], PG_lat=theta_list[["PG_lat"]],
  CL_lat=theta_list[["CL_lat"]], SS_lat=theta_list[["SS_lat"]],
  CR_lat=theta_list[["CR_lat"]], DM_lat=theta_list[["DM_lat"]]
)

# dat_obs: SOLO osservate
dat_obs <- data.frame(
  id=1:N,
  age_m=age_m,
  age_y=age_y,
  A=A,  # derivata dall'eta, utile per grafici (non e' "latente")
  # punteggi grezzi subtest range fisso
  SP=SP, RS=RS, CS=CS,
  MR=MR, RR=RR, QS=QS,
  MO=MO, RP=RP, MP=MP,
  SM=SM, PG=PG,
  CR=CR,
  # subtest a tempo/riconoscimento: componenti osservabili + score principale
  CL=CL, CL_correct=CL_correct, CL_error=CL_error, CL_omiss=CL_omiss, CL_attempt=CL_attempt,
  SS=SS, SS_hit=SS_hit, SS_fa=SS_fa, SS_omiss=SS_omiss,
  DM=DM, DM_hit=DM_hit, DM_fa=DM_fa
)

############################################################
# 5) VISUALIZZAZIONI (controllo plausibilita')
############################################################

# Check: latenti vs age (usa dat_lat, non dat_obs)
lat_vars <- c("g","Gc","Gf","Gv","Gwm","Gs","Glr")
lat_long <- cbind(dat_lat[,c("age_y","A")], stack(dat_lat[,lat_vars]))
names(lat_long)[3:4] <- c("value","factor")

ggplot(lat_long, aes(x=age_y, y=value, color=factor, fill=factor, group=factor)) +
  geom_smooth(method="loess", se=TRUE, linewidth=1, alpha=.3) +
  labs(title="Fattori latenti vs eta (controllo crescita)", x="Eta (anni)", y="Valore latente")

# Check estremi: "peggiore 20 ~ migliore 6" su g
g6  <- dat_lat$g[dat_lat$age_y >= 6  & dat_lat$age_y < 6.5]
g20 <- dat_lat$g[dat_lat$age_y >= 19.5 & dat_lat$age_y < 20.5]
q6_hi  <- unname(quantile(g6,  probs=.999))
q20_lo <- unname(quantile(g20, probs=.001))

cat("\nCHECK quantili estremi su g:\n")
cat("  g (6 anni)  99.9% =", round(q6_hi,2), "\n")
cat("  g (20 anni) 0.1%  =", round(q20_lo,2), "\n")
cat("  diff (20lo - 6hi) =", round(q20_lo - q6_hi,2), "\n\n")

# Grezzi vs eta: tutti i 15 subtest (score principali)
raw_main <- dat_obs[, c("SP","RS","CS","MR","RR","QS","MO","RP","MP","SM","PG","CR","CL","SS","DM")]
raw_long <- cbind(dat_obs[,c("age_y")], stack(raw_main))
names(raw_long) <- c("age_y","score","subtest")

ggplot(raw_long, aes(x=age_y, y=score)) +
  facet_wrap(~subtest, scales = "free_y") +
  geom_point(alpha=.08, size=.6) +
  geom_smooth(method="loess", se=TRUE, linewidth=1) +
  labs(title="Punteggi grezzi (score principali) vs eta",
       x="Eta (anni)", y="Grezzo")

#########################

# # Additional Checks
# 
# # Distribuzioni grezzi per eta-chiave
# age_key <- c(6,10,14,18,22)
# dat_obs$age_key <- NA
# for(a in age_key){
#   dat_obs$age_key[dat_obs$age_y >= (a-0.5) & dat_obs$age_y < (a+0.5)] <- a
# }
# dat_key <- dat_obs[!is.na(dat_obs$age_key), ]
# 
# raw_key_long <- cbind(dat_key[,c("age_key")], stack(dat_key[, names(raw_main)]))
# names(raw_key_long) <- c("age_key","score","subtest")
# 
# ggplot(raw_key_long, aes(x=score)) +
#   geom_histogram(bins=30) +
#   facet_grid(subtest ~ age_key, scales="free_x") +
#   labs(title="Distribuzioni grezzi per gruppo età (±0.5 anni)", x="Grezzo", y="Conteggi")
# 
# # Subtest a tempo: componenti CL e SS
# cl_long <- data.frame(
#   age_y = dat_obs$age_y,
#   correct = dat_obs$CL_correct,
#   error   = dat_obs$CL_error,
#   omiss   = dat_obs$CL_omiss,
#   score   = dat_obs$CL,
#   attempt = dat_obs$CL_attempt
# )
# cl_stack <- cbind(cl_long["age_y"], stack(cl_long[,c("score","correct","error","omiss","attempt")]))
# names(cl_stack)[2:3] <- c("value","metric")
# 
# ggplot(cl_stack, aes(x=age_y, y=value)) +
#   geom_point(alpha=.08, size=.6) +
#   geom_smooth(method="loess", se=TRUE, linewidth=1) +
#   facet_wrap(~metric, scales="free_y", ncol=3) +
#   labs(title="CL: componenti osservate vs eta", x="Eta (anni)", y="Valore")
# 
# ss_long <- data.frame(
#   age_y = dat_obs$age_y,
#   score = dat_obs$SS,
#   hit   = dat_obs$SS_hit,
#   fa    = dat_obs$SS_fa,
#   omiss = dat_obs$SS_omiss
# )
# ss_stack <- cbind(ss_long["age_y"], stack(ss_long[,c("score","hit","fa","omiss")]))
# names(ss_stack)[2:3] <- c("value","metric")
# 
# ggplot(ss_stack, aes(x=age_y, y=value)) +
#   geom_point(alpha=.08, size=.6) +
#   geom_smooth(method="loess", se=TRUE, linewidth=1) +
#   facet_wrap(~metric, scales="free_y", ncol=2) +
#   labs(title="SS: componenti osservate vs eta", x="Eta (anni)", y="Valore")
# 
# Correlazioni tra subtest (solo score principali) come heatmap
# cors <- cor(raw_main)
# cors_df <- as.data.frame(as.table(cors))
# names(cors_df) <- c("v1","v2","r")
# 
# ggplot(cors_df, aes(x=v1, y=v2, fill=r)) +
#   geom_tile() +
#   geom_text(aes(label=sprintf("%.2f", r)), size=3) +
#   theme(axis.text.x = element_text(angle=45, hjust=1)) +
#   labs(title="Correlazioni tra subtest (score principali)", x=NULL, y=NULL)

############################################################

# EXPORT RAW DATA

df <- dat_obs[order(dat_obs$age_y), ]
df$ID = 1:nrow(df)
vars <- c("SP","RS","CS","MR","RR","QS","MO","RP","MP","SM","PG","CR","CL","SS","DM")
df_export <- df[, c("ID", "age_y", vars)]
names(df_export)[names(df_export) %in% vars] <- paste0(vars, "_grezzo")
write.csv(
  df_export,
  "norms_BII/standardization_sample_raw.csv",
  row.names = FALSE
)

############################################################
