# -----------------------------------------------------------------------------
#
# Primary analytic code for:
# Real-world effectiveness of nirsevimab over three RSV seasons in an 
# integrated health care system: a target trial emulation study
# 
# Authors: Sara S Kim, Emily Wu, Alexander F Hudgins, Mackenzie Crawford,
# Marina Bruck, Felipe Lobelo, David Benkeser, Elizabeth T Rogawski McQuade
# 
# November 24, 2026
# 
# -----------------------------------------------------------------------------


# --- Load libraries
devtools::install_github("https://github.com/ewu16/nomatch")
library(nomatch)
library(tidyverse)

# --- Load dataset
analysis_data <- readRDS() # add in path to dataset here


# --- RSV hospitalization
future::plan(future::multisession, workers = 4)
start <- Sys.time()
rsv_hosp_fit <- nomatch(data = analysis_data, 
                        outcome_time = "fu_time_rsv_hosp",
                        outcome_status = "rsv_hosp",
                        exposure = "mab_binary",
                        exposure_time = "timetomab",
                        covariates = c("sin_doy","cos_doy","season",
                                       "maternal_age", "prenatal_encs_impute", "preterm_impute",
                                       "circulatory_malform_binary", "pulmonary_mal_binary", "neuromuscular_binary",
                                       "mat_flu_new", "mat_tdap_new","R_BLACK.x"),
                        immune_lag = 0, 
                        timepoints = seq(0, 180, by = 30),
                        boot_reps = 1000)

end <- Sys.time()
end - start 
future::plan(future::sequential) 

rsv_hosp_fit$estimates


# --- Medically attended rsv
future::plan(future::multisession, workers = 4)
start <- Sys.time()
rsv_ma_fit <- nomatch(data = analysis_data, 
                      outcome_time = "fu_time_rsv_ma",
                      outcome_status = "rsv_ma",
                      exposure = "mab_binary",
                      exposure_time = "timetomab",
                      covariates = c("sin_doy","cos_doy","season",
                                     "maternal_age", "prenatal_encs_impute", "preterm_impute",
                                     "circulatory_malform_binary", "pulmonary_mal_binary", "neuromuscular_binary",
                                     "mat_flu_new", "mat_tdap_new","R_BLACK.x"),
                      immune_lag = 0, 
                      timepoints = seq(0, 180, by = 30),
                      boot_reps = 1000)

end <- Sys.time()
end - start 
future::plan(future::sequential) 

rsv_ma_fit$estimates


# --- Bronchiolitis hospitalization 
future::plan(future::multisession, workers = 4)
start <- Sys.time()
bronc_hosp_fit <- nomatch(data = analysis_data, 
                          outcome_time = "fu_time_bronc_hosp",
                          outcome_status = "bronc_hosp",
                          exposure = "mab_binary",
                          exposure_time = "timetomab",
                          covariates = c("sin_doy","cos_doy","season",
                                         "maternal_age", "prenatal_encs_impute", "preterm_impute",
                                         "circulatory_malform_binary", "pulmonary_mal_binary", "neuromuscular_binary",
                                         "mat_flu_new", "mat_tdap_new","R_BLACK.x"),
                          immune_lag = 0, 
                          timepoints = seq(0, 180, by = 30),
                          boot_reps = 1000)

end <- Sys.time()
end - start 
future::plan(future::sequential) 

bronc_hosp_fit$estimates


# --- Medically attended bronchiolitis 
future::plan(future::multisession, workers = 4)
start <- Sys.time()
bronc_ma_fit <- nomatch(data = analysis_data, 
                        outcome_time = "fu_time_bronc_ma",
                        outcome_status = "bronc_ma",
                        exposure = "mab_binary",
                        exposure_time = "timetomab",
                        covariates = c("sin_doy","cos_doy","season",
                                       "maternal_age", "prenatal_encs_impute", "preterm_impute",
                                       "circulatory_malform_binary", "pulmonary_mal_binary", "neuromuscular_binary",
                                       "mat_flu_new", "mat_tdap_new","R_BLACK.x"),
                        immune_lag = 0, 
                        timepoints = seq(0, 180, by = 30),
                        boot_reps = 1000)

end <- Sys.time()
end - start 
future::plan(future::sequential) 

bronc_ma_fit$estimates


# --- ARI hospitalization 
future::plan(future::multisession, workers = 4)
start <- Sys.time()
ari_hosp_fit <- nomatch(data = analysis_data, 
                        outcome_time = "fu_time_ari_hosp",
                        outcome_status = "ari_hosp",
                        exposure = "mab_binary",
                        exposure_time = "timetomab",
                        covariates = c("sin_doy","cos_doy","season",
                                       "maternal_age", "prenatal_encs_impute", "preterm_impute",
                                       "circulatory_malform_binary", "pulmonary_mal_binary", "neuromuscular_binary",
                                       "mat_flu_new", "mat_tdap_new","R_BLACK.x"),
                        immune_lag = 0, 
                        timepoints = seq(0, 180, by = 30),
                        boot_reps = 1000)

end <- Sys.time()
end - start 
future::plan(future::sequential) 

ari_hosp_fit$estimates


# --- Medically attended ARI
future::plan(future::multisession, workers = 4)
start <- Sys.time()
ari_ma_fit <- nomatch(data = analysis_data, 
                      outcome_time = "fu_time_ari_ma",
                      outcome_status = "ari_ma",
                      exposure = "mab_binary",
                      exposure_time = "timetomab",
                      covariates = c("sin_doy","cos_doy","season",
                                     "maternal_age", "prenatal_encs_impute", "preterm_impute",
                                     "circulatory_malform_binary", "pulmonary_mal_binary", "neuromuscular_binary",
                                     "mat_flu_new", "mat_tdap_new","R_BLACK.x"),
                      immune_lag = 0, 
                      timepoints = seq(0, 180, by = 30),
                      boot_reps = 1000)

end <- Sys.time()
end - start 
future::plan(future::sequential) 

ari_ma_fit$estimates


# -- Medically attended rsv second season
analysis_second_season <- analysis_data %>%
  filter(season %in% c("2022-2023","2023-2024","2024-2025"))

future::plan(future::multisession, workers = 5)
start <- Sys.time()
rsv_ma_second_season <- nomatch(data = analysis_second_season, 
                                outcome_time = "fu_time_rsv_ma",
                                outcome_status = "rsv_ma",
                                exposure = "mab_binary",
                                exposure_time = "timetomab",
                                covariates = c("sin_doy","cos_doy","season",
                                               "maternal_age", "prenatal_encs_impute", "preterm_impute",
                                               "circulatory_malform_binary", "pulmonary_mal_binary", "neuromuscular_binary",
                                               "mat_flu_new", "mat_tdap_new","R_BLACK.x"),
                                immune_lag = 0, 
                                timepoints = seq(0, 720, by = 30),
                                boot_reps = 1000)

end <- Sys.time()
end - start # 
future::plan(future::sequential) 

rsv_ma_second_season$estimates
