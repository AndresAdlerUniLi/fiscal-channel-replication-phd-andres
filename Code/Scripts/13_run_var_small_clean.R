rm(list = ls())
cat("\014")

# ==========================================
# 13_run_var_small_clean.R
# Clean small VAR using fresh clean dataset
# ==========================================

needed_packages <- c("vars")

for (p in needed_packages) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p)
  }
  library(p, character.only = TRUE)
}

var_df_clean <- read.csv(
  "Data_Processing/Final_VAR_Dataset/var_dataset_replication_clean.csv",
  stringsAsFactors = FALSE
)

var_df_clean$date <- as.Date(var_df_clean$date)

# Small baseline VAR
var_data_clean <- var_df_clean[, c(
  "EBP",
  "Treasury_1Y",
  "Unemployment_Rate",
  "dlog_GDP",
  "dlog_CPI"
)]

cat("Any NA left in VAR input:", any(is.na(var_data_clean)), "\n")
print(colSums(is.na(var_data_clean)))

lag_selection_clean <- VARselect(var_data_clean, lag.max = 8, type = "const")
print(lag_selection_clean)

chosen_lag_clean <- as.numeric(lag_selection_clean$selection["AIC(n)"])
cat("Chosen lag:", chosen_lag_clean, "\n")

var_model_clean <- VAR(
  y = var_data_clean,
  p = chosen_lag_clean,
  type = "const"
)

dir.create("Outputs", recursive = TRUE, showWarnings = FALSE)
dir.create("Outputs/VAR_small_clean", recursive = TRUE, showWarnings = FALSE)
dir.create("Outputs/VAR_small_clean/IRF", recursive = TRUE, showWarnings = FALSE)

saveRDS(var_model_clean, "Outputs/VAR_small_clean/var_model_small_clean.rds")

capture.output(
  lag_selection_clean,
  file = "Outputs/VAR_small_clean/lag_selection_small_clean.txt"
)

capture.output(
  summary(var_model_clean),
  file = "Outputs/VAR_small_clean/var_model_small_summary_clean.txt"
)

irf_ebp_clean <- irf(
  var_model_clean,
  impulse = "EBP",
  response = c(
    "Treasury_1Y",
    "Unemployment_Rate",
    "dlog_GDP",
    "dlog_CPI"
  ),
  n.ahead = 12,
  boot = TRUE,
  ci = 0.95,
  runs = 500
)

saveRDS(irf_ebp_clean, "Outputs/VAR_small_clean/IRF/irf_ebp_small_clean.rds")

pdf("Outputs/VAR_small_clean/IRF/irf_ebp_small_clean.pdf", width = 9, height = 7)
plot(irf_ebp_clean)
dev.off()

stability_roots_clean <- roots(var_model_clean)

capture.output(
  stability_roots_clean,
  file = "Outputs/VAR_small_clean/var_roots_small_clean.txt"
)

cat("Rows in estimation sample:", nrow(var_data_clean), "\n")
cat("Columns in estimation sample:", ncol(var_data_clean), "\n")
print(stability_roots_clean)