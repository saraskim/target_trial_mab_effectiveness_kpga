# -----------------------------------------------------------------------------
# 
# Sensitivity analyses
# 1: 7 day lag in immunity
# 2: 90 day run out period
# 
# -----------------------------------------------------------------------------

# --- Set up
library(nomatch)
library(tidyverse)

analysis_data <- readRDS()



# ---------- Seven day immune lag ---------- #

# -- RSV hospitalization
future::plan(future::multisession, workers = 4)
start <- Sys.time()
rsv_hosp_immune7_fit <- nomatch(data = analysis_data, 
                        outcome_time = "fu_time_rsv_hosp",
                        outcome_status = "rsv_hosp",
                        exposure = "mab_binary",
                        exposure_time = "timetomab",
                        covariates = c("sin_doy","cos_doy","season",
                                       "maternal_age", "prenatal_encs_impute", "preterm_impute",
                                       "circulatory_malform_binary", "pulmonary_mal_binary", "neuromuscular_binary",
                                       "mat_flu_new", "mat_tdap_new","R_BLACK.x"),
                        immune_lag = 7, 
                        timepoints = seq(0, 180, by = 30),
                        boot_reps = 1000)

end <- Sys.time()
end - start 
future::plan(future::sequential) 

rsv_hosp_immune7_fit$estimates


# -- medically-attended rsv 
future::plan(future::multisession, workers = 4)
start <- Sys.time()
rsv_ma_immune7_fit <- nomatch(data = analysis_data, 
                                outcome_time = "fu_time_rsv_ma",
                                outcome_status = "rsv_ma",
                                exposure = "mab_binary",
                                exposure_time = "timetomab",
                                covariates = c("sin_doy","cos_doy","season",
                                               "maternal_age", "prenatal_encs_impute", "preterm_impute",
                                               "circulatory_malform_binary", "pulmonary_mal_binary", "neuromuscular_binary",
                                               "mat_flu_new", "mat_tdap_new","R_BLACK.x"),
                                immune_lag = 7, 
                                timepoints = seq(0, 180, by = 30),
                                boot_reps = 1000)

end <- Sys.time()
end - start 
future::plan(future::sequential) 

rsv_ma_immune7_fit$estimates




# ---------- run to 90 days ---------# 
analysis_new_runout <- analysis_data %>%
  mutate(new_last_study_date = as.Date('2026-03-16'),
         new_date_end_rsv_hosp = pmin(new_last_study_date, first_rsv_hosp_date, overall_enr_end, na.rm = TRUE),
         new_date_end_rsv_ma = pmin(new_last_study_date, first_rsv_ma_date, overall_enr_end, na.rm = TRUE),
         new_fu_time_rsv_hosp = as.numeric(new_date_end_rsv_hosp - BIRTH_DATE.x),
         new_fu_time_rsv_ma = as.numeric(new_date_end_rsv_ma - BIRTH_DATE.x)) %>%
  filter(new_fu_time_rsv_ma > -1) 

# -- RSV hospitalization
future::plan(future::multisession, workers = 4)
start <- Sys.time()
rsv_hosp_runout_fit <- nomatch(data = analysis_new_runout, 
                            outcome_time = "new_fu_time_rsv_hosp",
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

rsv_hosp_runout_fit$estimates



# -- medically attended RSV
future::plan(future::multisession, workers = 4)
start <- Sys.time()
rsv_ma_runout_fit <- nomatch(data = analysis_new_runout, 
                               outcome_time = "new_fu_time_rsv_ma",
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

rsv_ma_runout_fit$estimates
