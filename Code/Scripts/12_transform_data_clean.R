rm(list = ls())
cat("\014")

# ==========================================
# 12_transform_data_clean.R
# Clean transform script with fresh outputs
# ==========================================

master_raw <- read.csv(
  "Data_Processing/Raw_Combined/master_dataset_raw_clean.csv",
  stringsAsFactors = FALSE
)

master_raw$date <- as.Date(master_raw$date)

# Keep only quarterly rows
master_q <- master_raw[format(master_raw$date, "%m") %in% c("01", "04", "07", "10"), ]
master_q <- master_q[order(master_q$date), ]
row.names(master_q) <- NULL

# Transform to quarterly percentage log growth
master_q$dlog_GDP <- c(NA, diff(log(master_q$GDP))) * 100
master_q$dlog_CPI <- c(NA, diff(log(master_q$CPI))) * 100
master_q$dlog_Government_Spending <- c(NA, diff(log(master_q$Government_Spending))) * 100
master_q$dlog_Government_Transfers <- c(NA, diff(log(master_q$Government_Transfers))) * 100
master_q$dlog_Tax_Revenues <- c(NA, diff(log(master_q$Tax_Revenues))) * 100

# Build clean replication dataset
var_data_clean <- master_q[, c(
  "date",
  "EBP",
  "Treasury_1Y",
  "Treasury_2Y",
  "Treasury_5Y",
  "Treasury_10Y",
  "Unemployment_Rate",
  "dlog_GDP",
  "dlog_CPI",
  "dlog_Government_Spending",
  "dlog_Government_Transfers",
  "dlog_Tax_Revenues"
)]

# Keep only complete rows
var_df_clean <- var_data_clean[complete.cases(var_data_clean), ]
row.names(var_df_clean) <- NULL

dir.create("Data_Processing/Final_VAR_Dataset", recursive = TRUE, showWarnings = FALSE)

write.csv(
  var_df_clean,
  "Data_Processing/Final_VAR_Dataset/var_dataset_replication_clean.csv",
  row.names = FALSE
)

cat("Rows in quarterly dataset:", nrow(master_q), "\n")
cat("Rows in clean VAR dataset:", nrow(var_df_clean), "\n")
cat("Columns in clean VAR dataset:", ncol(var_df_clean), "\n")

print(names(var_df_clean))
print(head(var_df_clean, 5))
print(tail(var_df_clean, 5))
print(colSums(is.na(var_df_clean)))

# Key scaling check
cat("\nRange dlog_GDP:\n")
print(range(var_df_clean$dlog_GDP, na.rm = TRUE))

cat("\nRange dlog_CPI:\n")
print(range(var_df_clean$dlog_CPI, na.rm = TRUE))
