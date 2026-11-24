# ----------------------------------------------------------------------------
#
# Code for figure 2
# 
# ----------------------------------------------------------------------------


# --- Load libraries
library(tidyverse)
library(patchwork)
library(scales)

# --- Format data

# Cumulative incidence by outcome, follow-up day, and group.
# Day 0 is added manually as a deterministic anchor point (CI = 0 for both
# groups at time of receipt). For RSV hospitalization at days 30 and 60,
# recipients had zero observed events, so no CI was reported; lower/upper
# are set to 0 here to keep the ribbon continuous rather than introducing
# a gap for an interval that was never estimable.
ci_data <- tribble(
  ~outcome,                 ~day, ~group,                  ~ci_est, ~ci_lower, ~ci_upper,
  "RSV hospitalization",    0,    "No nirsevimab",               0.0000,  0.0000,    0.0000,
  "RSV hospitalization",    30,   "No nirsevimab",               0.0013,  0.0007,    0.0026,
  "RSV hospitalization",    60,   "No nirsevimab",               0.0028,  0.0015,    0.0053,
  "RSV hospitalization",    90,   "No nirsevimab",               0.0044,  0.0024,    0.0081,
  "RSV hospitalization",    120,  "No nirsevimab",               0.0053,  0.0030,    0.0094,
  "RSV hospitalization",    150,  "No nirsevimab",               0.0061,  0.0036,    0.0106,
  "RSV hospitalization",    180,  "No nirsevimab",               0.0072,  0.0043,    0.0120,
  "RSV hospitalization",    0,    "Nirsevimab recipient",  0.0000,  0.0000,    0.0000,
  "RSV hospitalization",    30,   "Nirsevimab recipient",  0.0000,  0.0000,    0.0000,
  "RSV hospitalization",    60,   "Nirsevimab recipient",  0.0000,  0.0000,    0.0000,
  "RSV hospitalization",    90,   "Nirsevimab recipient",  0.0004,  0.0001,    0.0011,
  "RSV hospitalization",    120,  "Nirsevimab recipient",  0.0004,  0.0001,    0.0011,
  "RSV hospitalization",    150,  "Nirsevimab recipient",  0.0004,  0.0001,    0.0011,
  "RSV hospitalization",    180,  "Nirsevimab recipient",  0.0004,  0.0001,    0.0011,
  "Medically-attended RSV", 0,    "No nirsevimab",               0.0000,  0.0000,    0.0000,
  "Medically-attended RSV", 30,   "No nirsevimab",               0.0056,  0.0043,    0.0072,
  "Medically-attended RSV", 60,   "No nirsevimab",               0.0108,  0.0085,    0.0139,
  "Medically-attended RSV", 90,   "No nirsevimab",               0.0174,  0.0136,    0.0222,
  "Medically-attended RSV", 120,  "No nirsevimab",               0.0237,  0.0186,    0.0301,
  "Medically-attended RSV", 150,  "No nirsevimab",               0.0302,  0.0238,    0.0382,
  "Medically-attended RSV", 180,  "No nirsevimab",               0.0374,  0.0295,    0.0473,
  "Medically-attended RSV", 0,    "Nirsevimab recipient",  0.0000,  0.0000,    0.0000,
  "Medically-attended RSV", 30,   "Nirsevimab recipient",  0.0024,  0.0008,    0.0067,
  "Medically-attended RSV", 60,   "Nirsevimab recipient",  0.0042,  0.0019,    0.0094,
  "Medically-attended RSV", 90,   "Nirsevimab recipient",  0.0094,  0.0055,    0.0158,
  "Medically-attended RSV", 120,  "Nirsevimab recipient",  0.0107,  0.0067,    0.0173,
  "Medically-attended RSV", 150,  "Nirsevimab recipient",  0.0107,  0.0067,    0.0173,
  "Medically-attended RSV", 180,  "Nirsevimab recipient",  0.0122,  0.0078,    0.0192
)

# Relative risk reduction by outcome and day. NA where not estimable
# (zero events among recipients through day 60 for hospitalization).
rrr_data <- tribble(
  ~outcome,                 ~day, ~rrr_est, ~rrr_lower, ~rrr_upper,
  "RSV hospitalization",    30,   NA,    NA,     NA,
  "RSV hospitalization",    60,   NA,    NA,     NA,
  "RSV hospitalization",    90,   0.92,  0.72,   0.98,
  "RSV hospitalization",    120,  0.93,  0.77,   0.98,
  "RSV hospitalization",    150,  0.94,  0.81,   0.98,
  "RSV hospitalization",    180,  0.95,  0.84,   0.98,
  "Medically-attended RSV", 30,   0.57,  -0.25,  0.85,
  "Medically-attended RSV", 60,   0.61,  0.10,  0.83,
  "Medically-attended RSV", 90,   0.46,  0.04,   0.70,
  "Medically-attended RSV", 120,  0.55,  0.22,   0.74,
  "Medically-attended RSV", 150,  0.64,  0.39,   0.79,
  "Medically-attended RSV", 180,  0.67,  0.45,   0.80
)

outcome_levels <- c("RSV hospitalization", "Medically-attended RSV")
ci_data  <- mutate(ci_data,  outcome = factor(outcome, levels = outcome_levels))
rrr_data <- mutate(rrr_data, outcome = factor(outcome, levels = outcome_levels))



# --- Convert landmark estimates into step-function form

# Cumulative incidence is right-continuous and constant between estimated
# time points, so the plotted curve (and its ribbon) should step rather
# than interpolate linearly between landmark days.
stepify <- function(df) {
  df <- df[order(df$day), ]
  n <- nrow(df)
  if (n < 2) return(df)
  out <- df[1, , drop = FALSE]
  for (i in seq_len(n - 1)) {
    carry <- df[i, ]
    carry$day <- df$day[i + 1]
    out <- rbind(out, carry, df[i + 1, ])
  }
  out
}

ci_step <- ci_data %>%
  group_by(outcome, group) %>%
  group_modify(~ stepify(.x)) %>%
  ungroup()



# --- Color palette 
group_colors <- c("No nirsevimab" = "#0072B2", "Nirsevimab recipient" = "#D55E00")




# --- Plot functions
plot_ci <- function(data, outcome_name) {
  d <- filter(data, outcome == outcome_name)
  ggplot(d, aes(x = day, y = ci_est, color = group, fill = group)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15, color = NA) +
    geom_step(linewidth = 0.8) +
    scale_color_manual(values = group_colors, name = NULL) +
    scale_fill_manual(values = group_colors, name = NULL) +
    scale_x_continuous(breaks = seq(0, 180, 30)) +
    scale_y_continuous(labels = label_percent(accuracy = 0.01)) +
    labs(x = "Days from nirsevimab receipt", y = "Cumulative incidence",
         title = outcome_name) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "top",
          panel.grid.minor = element_blank(),
          plot.title = element_text(face = "plain", size = 13))
}

plot_forest <- function(data, outcome_name) {
  d <- filter(data, outcome == outcome_name) %>%
    mutate(day_label = factor(day, levels = sort(unique(day))))
  ggplot(d, aes(x = day_label, y = rrr_est)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
    geom_pointrange(aes(ymin = rrr_lower, ymax = rrr_upper),
                    color = "#3D5A73", size = 0.7, linewidth = 0.9, na.rm = TRUE) +
    scale_y_continuous(labels = label_percent(),
                       breaks = seq(-0.25, 1, by = 0.25)) +
    coord_cartesian(ylim = c(-0.3, 1)) +
    labs(x = "Days from nirsevimab receipt", y = "Relative risk reduction (95% CI)",
         title = outcome_name) +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank(),
          plot.title = element_text(face = "plain", size = 13))
}



# --- Build and combine panels

p_hosp_ci      <- plot_ci(ci_step, "RSV hospitalization")
p_hosp_forest  <- plot_forest(rrr_data, "RSV hospitalization")
p_marsv_ci     <- plot_ci(ci_step, "Medically-attended RSV")
p_marsv_forest <- plot_forest(rrr_data, "Medically-attended RSV")

final_fig <- (p_hosp_ci | p_hosp_forest) / (p_marsv_ci | p_marsv_forest) +
  plot_annotation(
    tag_levels = "A",
    caption = "RRR not shown for RSV hospitalization at days 30 and 60: zero events observed among recipients."
  )

