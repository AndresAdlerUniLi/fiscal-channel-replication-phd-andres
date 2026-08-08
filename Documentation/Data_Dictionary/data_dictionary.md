# Data Dictionary — Baseline BPSVAR (Table A.1)

Authoritative mapping of paper variables → source codes → current repo status.
Frequency: quarterly. Sample: 1983Q1–2019Q4. "Transform" is the form entering the VAR (yₜ).

## Baseline endogenous vector yₜ (8 variables, p=4)

| # | Variable | Source | Code | Transform in VAR | Repo status |
|---|----------|--------|------|------------------|-------------|
| 1 | Real GDP | FRED | GDPC1 | log level ×100 | Have (as GDP_quarterly); currently dlog — fix |
| 2 | GDP deflator | FRED | **GDPCTPI** | log level ×100 | Have GDPDEF (wrong code) — replace |
| 3 | Excess bond premium | Fed Board (Favara et al., updated GZ) | ebp | level | Have cleaned EBP — verify it's the updated series |
| 4 | 1-year Treasury yield | FRED | **GS1** | level | Have daily DGS1 — average to quarterly, or use GS1 |
| 5 | Fiscal deficit ratio | FRED (constructed) | (W019RCQ027SBEA − W018RC1Q027SBEA)/GDP | level (ratio) | Wrong (annual FYFSD) — rebuild |
| 6 | Real tax revenues | FRED | **W018RC1Q027SBEA** / GDPCTPI | log level ×100 | Have wrong code (W006) — replace |
| 7 | Real social transfers | FRED | W823RC1 / GDPCTPI | log level ×100 | Have W823RC1 — deflate + log-level |
| 8 | Real gov. spending | FRED | GCEC1 | log level ×100 | Have GCEC1 — log-level |

Supporting series needed but not in yₜ: **GDP** (nominal, deficit denominator),
**GDPCTPI** (deflator for real tax/transfers).

## Identification proxies (external instruments) — NOT YET IN REPO

| Shock | Proxy | Source |
|-------|-------|--------|
| Monetary policy | FF4 high-frequency surprise (3-mo ahead fed funds future, 30-min FOMC window) | Gürkaynak et al. (2022); Swanson (2021) factor for robustness |
| Tax | Narrative legislated tax shocks (anticipation-adjusted), extended | Mertens & Ravn (2011), extended by authors to 2019Q4 |
| Transfers | Narrative social-transfer shocks, extended | Romer & Romer (2016), extended by authors |
| Gov. spending | Government spending forecast error | Caldara & Kamps (2017) |

Note: authors *extended* several proxies to sample end — exact match may require their
replication package (see logbook Phase 0 open action).

## Robustness / extension series present in repo (not baseline)
Treasury 2/3/5/10y, DFF (fed funds), UNRATE, PAYEMS, AWHMAN (broken), DSPIC96 (disposable
income), GPSAVE (private savings), PCECC96 (consumption), INDPRO, CPIAUCSL. Keep labeled as
extensions; do not leak into the baseline dataset.
