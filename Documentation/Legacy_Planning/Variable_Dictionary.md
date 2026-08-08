# Variable Dictionary

| Paper Variable | Code Name | Source | FRED Code / Dataset | Frequency | Transformation | Status |
|---|---|---|---|---|---|---|
| Real GDP | real_gdp | FRED | GDPC1 | Quarterly | log × 100 | Pending |
| Nominal GDP | nominal_gdp | FRED | GDP | Quarterly | level | Pending |
| GDP Deflator | gdp_deflator | FRED | GDPCTPI | Quarterly | log × 100 | Pending |
| Excess Bond Premium | ebp | Gilchrist & Zakrajšek / Fed | EBP series | Quarterly | level | Pending |
| 1-Year Treasury Rate | treasury_1y | FRED | GS1 | Quarterly | level | Pending |
| Fiscal Expenditures | fiscal_expenditures | FRED | W019RCQ027SBEA | Quarterly | level | Pending |
| Tax Revenues | tax_revenues | FRED | W018RC1Q027SBEA | Quarterly | deflate + log × 100 | Pending |
| Fiscal Deficit Ratio | fiscal_deficit_ratio | Constructed | expenditures - revenues / GDP | Quarterly | level | Pending |
| Social Transfers | social_transfers | FRED | W823RC1 | Quarterly | deflate + log × 100 | Pending |
| Government Spending | gov_spending | FRED | GCEC1 | Quarterly | log × 100 | Pending |
| Monetary Policy Shock Proxy | mp_proxy | High-Frequency Identification | Gürkaynak et al. surprises | Event / Quarterly | proxy aggregation | Pending |
| Tax Shock Proxy | tax_proxy | Narrative Shock Series | Mertens-Ravn style | Quarterly | level | Pending |
| Transfer Shock Proxy | transfer_proxy | Narrative Shock Series | transfer shock series | Quarterly | level | Pending |
| Spending Shock Proxy | spending_proxy | Forecast Error Shock | spending forecast errors | Quarterly | level | Pending |