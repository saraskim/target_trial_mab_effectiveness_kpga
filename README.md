# Real-world effectiveness of nirsevimab over three RSV seasons: a target trial emulation study

Analytic code for:

> Kim SS, Wu E, Hudgins AF, Crawford M, Bruck M, Lobelo F, Benkeser D, Rogawski McQuade ET. Real-world effectiveness of nirsevimab over three RSV seasons in an integrated health care system: a target trial emulation study.

Preprint: https://www.medrxiv.org/content/10.64898/2026.11.12.26367940v1

## Overview

This study estimates the effectiveness of nirsevimab against respiratory syncytial virus (RSV) and related outcomes among infants at Kaiser Permanente Georgia across three RSV seasons (2023–2026). We emulated a target trial with the [`nomatch`](https://github.com/ewu16/nomatch) R package ([Wu et al., *Epidemiology*, 2026](https://www.ovid.com/jnls/epidem/abstract/10.1097/ede.0000000000001982~target-trial-emulation-without-matching-a-more-efficient?redirectionsource=fulltextview)). The method targets the same estimand as matching-based cohort studies but uses data from all eligible infants without explicit matching to define time zero. It estimates cumulative incidence among nirsevimab recipients and non-recipients, along with relative risk reduction, at 30-day intervals after receipt. Confidence intervals come from the bootstrap.

## Data availability

The individual-level data used in this study are not publicly available because of patient privacy protections. The scripts cannot be run without access to the underlying analytic dataset. Each script contains a `readRDS()` call where the path to the dataset should be added.

## Repository contents

| File | Description |
|---|---|
| `analytic_code.R` | **Primary analysis script.** Estimates nirsevimab effectiveness for all primary and secondary outcomes, plus the second-season analysis. |
| `sensitivity.R` | Sensitivity analyses: a 7-day immune lag and a 90-day run-out period. |
| `figure1.R` | Creates Figure 1: age at nirsevimab receipt by birth month. |
| `figure2.R` | Creates Figure 2: cumulative incidence curves and relative risk reduction for the primary outcomes. |

### `analytic_code.R` (primary analysis)

This script fits a `nomatch()` model for each outcome below. Follow-up starts at nirsevimab receipt, with no immune lag. Estimates are reported every 30 days from day 0 through day 180, with 1,000 bootstrap replicates.

| Outcome | Object |
|---|---|
| RSV hospitalization (primary) | `rsv_hosp_fit` |
| Medically attended RSV (primary) | `rsv_ma_fit` |
| Bronchiolitis hospitalization | `bronc_hosp_fit` |
| Medically attended bronchiolitis | `bronc_ma_fit` |
| Acute respiratory illness (ARI) hospitalization | `ari_hosp_fit` |
| Medically attended ARI | `ari_ma_fit` |
| Medically attended RSV through a second season | `rsv_ma_second_season` |

The second-season analysis keeps only infants from the seasons with enough follow-up to observe a second RSV season. It extends estimation to 720 days, again at 30-day intervals.

All models adjust for the following covariates:

| Variable | Description |
|---|---|
| `sin_doy`, `cos_doy` | Harmonic terms for day of year, which capture seasonality |
| `season` | RSV season |
| `maternal_age` | Maternal age |
| `prenatal_encs_impute` | Number of prenatal care encounters |
| `preterm_impute` | Preterm birth |
| `circulatory_malform_binary` | Congenital circulatory malformation |
| `pulmonary_mal_binary` | Congenital pulmonary malformation |
| `neuromuscular_binary` | Neuromuscular condition |
| `mat_flu_new` | Maternal influenza vaccination during pregnancy |
| `mat_tdap_new` | Maternal Tdap vaccination during pregnancy |
| `R_BLACK.x` | Black race |

Key analysis variables:

| Variable | Description |
|---|---|
| `mab_binary` | Nirsevimab receipt (1 = received, 0 = not received) |
| `timetomab` | Infant age in days at nirsevimab receipt |
| `fu_time_<outcome>` | Follow-up time in days for each outcome |
| `<outcome>` (e.g., `rsv_hosp`) | Outcome indicator (1 = event, 0 = censored) |

### `sensitivity.R`

This script repeats the two primary-outcome analyses (RSV hospitalization and medically attended RSV) under two alternative specifications:

1. **7-day immune lag** (`immune_lag = 7`). Assumes protection begins 7 days after receipt instead of immediately.
2. **90-day run-out period.** Extends the end of follow-up to March 16, 2026. Follow-up ends at the earliest of this date, the outcome, or the end of health plan enrollment. Infants with negative follow-up time are excluded.

### `figure1.R`

Creates a box plot of infant age at nirsevimab receipt by birth month, among nirsevimab recipients. Each x-axis label shows the number of recipients born in that month. Red bars show the range of ages on October 1 for infants born in each month.

### `figure2.R`

Creates a four-panel figure:

- **Panels A and C:** cumulative incidence of RSV hospitalization (A) and medically attended RSV (C) among recipients and non-recipients, drawn as step functions with 95% confidence bands.
- **Panels B and D:** relative risk reduction (95% CI) at each 30-day time point.

The estimates are entered directly from the output of `analytic_code.R` (`rsv_hosp_fit$estimates` and `rsv_ma_fit$estimates`), so this script does not need the individual-level data. Recipients had no RSV hospitalizations through day 60, so relative risk reduction could not be estimated at days 30 and 60 for that outcome and is not shown.

## Software requirements

Analyses were run in R version 4.4.2.

Bootstrap estimation runs in parallel with `future::plan(future::multisession, workers = 4)`. Change `workers` to suit your machine. Each model with 1,000 bootstrap replicates can take [X minutes/hours] to run.

## How to run

1. Install the required packages.
2. Add the path to the analytic dataset in the `readRDS()` call at the top of each script.
3. Run `analytic_code.R` for the primary and secondary analyses.
4. Run `sensitivity.R` for the sensitivity analyses.
5. Run `figure1.R` and `figure2.R` to create the figures.
