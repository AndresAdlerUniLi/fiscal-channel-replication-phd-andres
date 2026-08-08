rm(list = ls())
cat("\014")

# ==========================================
# 11_build_master_dataset_clean.R
# Clean rebuild of merged quarterly pipeline
# ==========================================

read_clean_series <- function(path) {
  df <- read.csv(path, stringsAsFactors = FALSE)
  df$date <- as.Date(df$date)
  df
}

base_path <- "Data_Processing/Cleaned_Data"

financial_path <- file.path(base_path, "Financial")
macro_path     <- file.path(base_path, "Macro")
fiscal_path    <- file.path(base_path, "Fiscal")
labor_path     <- file.path(base_path, "Labor_External")

# Financial
ebp <- read_clean_series(file.path(financial_path, "EBP_GilchristZakrajsek_quarterly.csv"))
t1y <- read_clean_series(file.path(financial_path, "Treasury_1Y_quarterly.csv"))
t2y <- read_clean_series(file.path(financial_path, "Treasury_2Y_quarterly.csv"))
t5y <- read_clean_series(file.path(financial_path, "Treasury_5Y_quarterly.csv"))
t10y <- read_clean_series(file.path(financial_path, "Treasury_10Y_quarterly.csv"))

# Macro
gdp    <- read_clean_series(file.path(macro_path, "GDP_quarterly.csv"))
cpi    <- read_clean_series(file.path(macro_path, "CPI_quarterly.csv"))
indpro <- read_clean_series(file.path(macro_path, "Industrial_Production_quarterly.csv"))
gdpdef <- read_clean_series(file.path(macro_path, "GDP_Deflator_quarterly.csv"))
cons   <- read_clean_series(file.path(macro_path, "Consumption_quarterly.csv"))
income <- read_clean_series(file.path(macro_path, "Disposable_Income_quarterly.csv"))
savings <- read_clean_series(file.path(macro_path, "Private_Savings_quarterly.csv"))

# Fiscal
spend     <- read_clean_series(file.path(fiscal_path, "Government_Spending_quarterly.csv"))
transfers <- read_clean_series(file.path(fiscal_path, "Government_Transfers_quarterly.csv"))
taxes     <- read_clean_series(file.path(fiscal_path, "Tax_Revenues_quarterly.csv"))

# Labor
unemp    <- read_clean_series(file.path(labor_path, "Unemployment_Rate_quarterly.csv"))
payrolls <- read_clean_series(file.path(labor_path, "Nonfarm_Payrolls_quarterly.csv"))
hours    <- read_clean_series(file.path(labor_path, "Hours_Worked_quarterly.csv"))

all_series <- list(
  ebp, t1y, t2y, t5y, t10y,
  gdp, cpi, indpro, gdpdef, cons, income, savings,
  spend, transfers, taxes,
  unemp, payrolls, hours
)

master_dataset_clean <- Reduce(function(x, y) merge(x, y, by = "date", all = TRUE), all_series)
master_dataset_clean <- master_dataset_clean[order(master_dataset_clean$date), ]
row.names(master_dataset_clean) <- NULL

dir.create("Data_Processing/Raw_Combined", recursive = TRUE, showWarnings = FALSE)

write.csv(
  master_dataset_clean,
  "Data_Processing/Raw_Combined/master_dataset_raw_clean.csv",
  row.names = FALSE
)

cat("Rows:", nrow(master_dataset_clean), "\n")
cat("Columns:", ncol(master_dataset_clean), "\n")
print(names(master_dataset_clean))
print(head(master_dataset_clean, 5))
print(tail(master_dataset_clean, 5))