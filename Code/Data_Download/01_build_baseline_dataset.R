# =====================================================================
# 01_build_baseline_dataset.R
# Phase 1 — Corrected data foundation for the baseline BPSVAR
# Paper: Breitenlechner, Geiger & Klein, "The Fiscal Channel of Monetary
# Policy" (Innsbruck WP 2024-07; forthcoming JPE Macro). Table A.1.
#
# Target: quarterly, 1983Q1–2019Q4, 8 endogenous variables, p = 4.
# Transform: log-levels x100 for real quantities & the price level;
#            LEVELS for the 1y yield, EBP, and the fiscal deficit ratio.
# Supersedes the earlier Code/Scripts/*_clean.R (which used growth rates,
# an annual FYFSD deficit, and wrong tax code). See Documentation logbook.
# =====================================================================

# ---- 0. Setup -------------------------------------------------------
# Requires a free FRED API key: https://fred.stlouisfed.org/docs/api/api_key.html
# install.packages(c("fredr","dplyr","lubridate","zoo"))
library(fredr); library(dplyr); library(lubridate); library(zoo)
# fredr_set_key("YOUR_KEY_HERE")   # <-- set once

START <- as.Date("1980-01-01")   # download from 1980; window later
END   <- as.Date("2019-12-31")

# ---- 1. Exact FRED series (Table A.1) -------------------------------
# code -> meaning. All from FRED except EBP (Fed Board, see step 3).
series <- c(
  GDPC1            = "real_GDP",            # real GDP (chained 2012 $)
  GDP              = "nominal_GDP",         # nominal GDP (deficit denominator)
  GDPCTPI          = "GDP_deflator",        # chain-type price index (NOT GDPDEF)
  GS1              = "y1_yield",            # 1-year treasury (quarterly avg)
  GCEC1            = "real_gov_spending",   # real government spending
  W823RC1          = "transfers_nom",       # social benefits (Social Security)
  W018RC1Q027SBEA  = "receipts_nom",        # federal total receipts (tax rev.)
  W019RCQ027SBEA   = "expenditures_nom"     # federal total expenditures
)

fetch <- function(id){
  fredr(series_id = id, observation_start = START, observation_end = END,
        frequency = "q", aggregation_method = "avg") |>       # -> quarterly avg
    transmute(date = floor_date(date, "quarter"),
              !!series[[id]] := value)
}
dat <- Reduce(function(a,b) full_join(a,b, by="date"),
              lapply(names(series), fetch)) |> arrange(date)

# ---- 2. EBP (Gilchrist–Zakrajšek, Favara et al. updated) ------------
# Source: Board of Governors FEDS Notes (ebp_csv.csv). Quarterly average.
# Place the raw file at Raw_Data/External_Datasets/Excess_Bond_Premium/ebp.csv
ebp_raw <- read.csv("Raw_Data/External_Datasets/Excess_Bond_Premium/ebp.csv")
ebp_raw$date <- as.Date(ebp_raw$date)
ebp_q <- ebp_raw |>
  mutate(date = floor_date(date, "quarter")) |>
  group_by(date) |> summarise(EBP = mean(ebp, na.rm = TRUE), .groups="drop")
dat <- left_join(dat, ebp_q, by = "date")

# ---- 3. Constructed variables ---------------------------------------
# Deflate nominal tax & transfers to real by the GDP price deflator.
dat <- dat |> mutate(
  real_tax_revenues    = receipts_nom      / (GDP_deflator/100),
  real_transfers       = transfers_nom     / (GDP_deflator/100),
  # Fiscal deficit ratio = (expenditures - receipts) / nominal GDP
  fiscal_deficit_ratio = (expenditures_nom - receipts_nom) / nominal_GDP
)

# ---- 4. Paper transforms: log-levels x100 (except yield/EBP/deficit) -
lvl_log <- c("real_GDP","GDP_deflator","real_gov_spending",
             "real_transfers","real_tax_revenues")
for (v in lvl_log) dat[[v]] <- log(dat[[v]]) * 100

# ---- 5. Assemble 8-variable baseline, window 1983Q1–2019Q4 ----------
baseline <- dat |>
  filter(date >= as.Date("1983-01-01"), date <= as.Date("2019-10-01")) |>
  transmute(date,
            real_GDP, GDP_deflator, EBP, y1_yield,
            fiscal_deficit_ratio, real_tax_revenues,
            real_transfers, real_gov_spending)

stopifnot(nrow(baseline) == 148)                       # 1983Q1–2019Q4
dir.create("Data_Processing/Final_VAR_Dataset", recursive = TRUE, showWarnings = FALSE)
write.csv(baseline,
          "Data_Processing/Final_VAR_Dataset/baseline_var_dataset_v2.csv",
          row.names = FALSE)
cat("Rows:", nrow(baseline), " NAs:\n"); print(colSums(is.na(baseline)))
