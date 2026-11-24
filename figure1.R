# ----------------------------------------------------------------------------
#
# Code for figure 1
# 
# ----------------------------------------------------------------------------

# --- Load library
library(tidyverse)
library(ggplot2)


# --- Load dataset
analysis_data <- readRDS() # add in path to dataset here


# --- Minor cleaning
mabs_only <- analysis_data %>%
  filter(mab_binary == 1) %>%
  mutate(birth_month_year = floor_date(BIRTH_DATE.x, "month"),
         month_label = format(birth_month_year, "%b-%Y"),
         Vaccine_1_vaccine_dt = as.Date(Vaccine_1_vaccine_dt),
         mab_month_year = floor_date(Vaccine_1_vaccine_dt, "month"),
         mab_month_label = format(mab_month_year, "%b-%Y")) %>%
  mutate(month_label = factor(
    month_label,
    levels = unique(month_label[order(birth_month_year)])),
    mab_month_label = factor(
      mab_month_label,
      levels = unique(mab_month_label[order(mab_month_year)]))
  )

# number of infants per birth month
n_df <- mabs_only %>%
  count(month_label, name = "n")

n_lookup <- setNames(n_df$n, as.character(n_df$month_label))

# label each month as "Month-Year" with "(n=...)" underneath
n_labeller <- function(x) {
  n <- n_lookup[as.character(x)]
  n[is.na(n)] <- 0                      # months with no recipients show n=0
  paste0(x, "\n(n=", n, ")")
}




# --- Plot code
ggplot(mabs_only, aes(x = month_label, y = timetomab)) +
  geom_boxplot(fill = "#B7C9DA", outlier.shape = NA) +
  geom_jitter(alpha = 0.2, width = 0.2) +
  geom_errorbar(
    data = elig_ref,
    aes(x = month_label, ymin = age_min, ymax = age_max, color = "Age (days) on October 1"),
    inherit.aes = FALSE, width = 0.7, linewidth = 0.8
  ) +
  scale_color_manual(values = c("Age (days) on October 1" = "firebrick"), name = NULL) +
  scale_x_discrete(labels = n_labeller) +
  scale_y_continuous(breaks = seq(0, 300, by = 50),
                     minor_breaks = seq(0, 300, by = 25)) +
  labs(
    x = "Birth Month-Year",
    y = "Age at nirsevimab receipt (days)"
  ) +
  theme_minimal(base_size = 12) +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y = element_line(color = "gray85", linewidth = 0.4),
        panel.grid.minor.y = element_line(color = "gray93", linewidth = 0.3),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 1, lineheight = 0.9),
        legend.position = "top") +
  coord_cartesian(ylim = c(0, 300))

