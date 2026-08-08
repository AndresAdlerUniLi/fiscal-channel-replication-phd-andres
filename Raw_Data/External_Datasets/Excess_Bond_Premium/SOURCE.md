# Excess Bond Premium (EBP) — source & provenance

**Series:** Excess Bond Premium, Gilchrist & Zakrajšek (2012), **updated by Favara, Gilchrist,
Lewis & Nakata (2016)** — the exact vintage the paper's Table A.1 specifies ("Favara et al.'s
(2016) updated EBP series, quarterly average").

**Official source:** Board of Governors of the Federal Reserve System, FEDS Notes,
"Updating the Recession Risk and the Excess Bond Premium."
Download: https://www.federalreserve.gov/econres/notes/feds-notes/ebp_csv.csv
(columns: date, gz_spread, ebp, est_prob; monthly, 1973M1–present.)

**Cleaned file used by the pipeline:**
`Data_Processing/Cleaned_Data/Financial/EBP_GilchristZakrajsek_quarterly.csv`
(monthly EBP → quarterly average.)

**Verification (2026-08-08):** confirmed our cleaned series IS the updated Favara et al. EBP:
- Coverage 1973Q1–2026Q1 (runs past 2010 ⇒ updated version, not original GZ-2012).
- 2008Q4 crisis peak = +3.30 (matches published EBP peak).
- mean ≈ 0.06, std ≈ 0.51, min −0.78 (2021 boom). Enters VAR in levels.

**Note:** the raw monthly `ebp_csv.csv` was not re-archived here (Fed server returns it as a
binary download that the fetch tool won't retrieve). To complete raw provenance, drop the
downloaded `ebp_csv.csv` into this folder. The cleaned quarterly series is verified and
sufficient for estimation.
