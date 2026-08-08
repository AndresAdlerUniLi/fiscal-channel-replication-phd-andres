# Proxy Sourcing Map — Identification Instruments (Phase 2)

The BPSVAR is identified by external instruments (proxies), one per structural shock.
Public "base" vintages are listed below. The paper uses the authors' **extended** versions
(through 2019Q4); base public versions end earlier — see the caveat at the bottom. In a
proxy-SVAR this is workable: the VAR is estimated on the full 1983Q1–2019Q4 sample and the
proxy is set to 0 in quarters with no event (standard convention).

Place downloads in `Raw_Data/Monetary_Shocks/` (monetary) and a new
`Raw_Data/External_Datasets/Fiscal_Proxies/` (tax, transfers, spending).

---

## 1. Monetary policy shock — FF4 high-frequency surprise
- **Paper:** baseline = Gürkaynak et al. (2022) FF4 (3-mo-ahead fed funds future surprise,
  30-min FOMC window), purged of information effects. Robustness = Jarociński–Karadi (2020)
  "poor man's" and Swanson (2021) target factor.
- **Best public source:** Jarociński & Karadi (2020) replication — "Download shocks":
  https://marekjarocinski.github.io/  (AEJ:Macro 2020). Contains the high-frequency interest-
  rate surprise (FF4-type) and the info-robust median-rotation series.
- **Robustness source:** Swanson (2021) factors (fed funds rate factor):
  https://sites.socsci.uci.edu/~swanson2/  (JME 2021).
- **Coverage / freq:** ~1990/1991–2019, per-announcement. **Align:** sum surprises within
  each quarter → quarterly proxy; 0 in quarters without an FOMC surprise of that type.

## 2. Tax shock — narrative legislated tax changes
- **Paper:** Mertens & Ravn (2011) unanticipated narrative tax shocks (anticipation-adjusted),
  extended; combined with Romer–Romer (2010) narrative for coverage.
- **Source:** Karel Mertens, Data & Matlab programs: https://karelmertens.com/research/
  (Review of Economic Dynamics 2011).
- **Coverage / freq:** quarterly, ~1950–2006 (base). **Align:** take the unanticipated series;
  quarterly; 0 elsewhere.

## 3. Transfer shock — Social Security benefit changes
- **Paper:** Romer & Romer (2016) extended narrative transfer series (Párraga Rodríguez 2018
  extends it).
- **Source:** openICPSR project 114107 (replication data):
  https://www.openicpsr.org/openicpsr/project/114107/version/V1/view  (login/free account).
  Backup: Christina Romer's page https://eml.berkeley.edu/~cromer/ .
- **Coverage / freq:** 1952–1991 (base). **Align:** quarterly; 0 elsewhere.

## 4. Government spending shock — forecast error
- **Paper:** government spending forecast error (Auerbach & Gorodnichenko 2012; Caldara &
  Kamps 2017 framework), extended to 2019Q4.
- **Source:** Gorodnichenko replication page https://eml.berkeley.edu/~ygorodni/ (AEJ:Policy
  2012). Reconstructable from SPF real federal spending forecasts (Philadelphia Fed) vs. realized.
- **Coverage / freq:** quarterly, ~1966–2012 (base). **Align:** real-time one-quarter-ahead
  forecast error of government spending; quarterly.

---

## Exact construction per the paper (Section 2.3) — narrative, not formulae
The paper NAMES each series and its published extension. Tax/transfers are narrative (download,
don't compute); spending is a forecast error (a formula, but needs real-time forecast data).

- **Tax proxy** = Mertens & Ravn (2011) narrative [→2006] **combined with Hanson et al. (2021)**
  [extends to 2019]. Uses only tax changes implemented ≤90 days after enactment (anticipation).
  → Get M&R 2011 from karelmertens.com; find Hanson et al. (2021) for the 2007–2019 extension.
- **Transfer proxy** = Romer & Romer (2016) narrative [→1991] **combined with Párraga Rodríguez
  (2018)** [extends to **2007 only**]; 2008–2019 set to 0. → openICPSR 114107 + Párraga Rodríguez
  (2018) replication.
- **Spending proxy** = government-spending **forecast error** (Auerbach–Gorodnichenko 2012,
  1966–2008), authors extend to 2019. Formula = realized real gov. spending − real-time
  one-quarter-ahead forecast (SPF, Philadelphia Fed). Reconstructable, or request authors' extension.
- **Missing periods → 0** (Paul 2020; Känzig 2023 convention); full 1983–2019 VAR sample retained.

## Precise download checklist (confirmed from the paper's bibliography)
| Proxy | Piece | Exact reference | Where to get it |
|-------|-------|-----------------|-----------------|
| Tax | base [→2006] | Mertens & Ravn (2011), *Rev. Econ. Dynamics* 14:27–54 | karelmertens.com/research (Data + Matlab; use *unanticipated* series) |
| Tax | ext [→2019] | Hanson, Hauser & Priftis (2021), Bank of Canada SWP **21-41** | bankofcanada.ca WP 21-41 replication / Priftis website |
| Transfers | base [→1991] | Romer & Romer (2016), AEJ:Macro | openICPSR **114107**; eml.berkeley.edu/~cromer |
| Transfers | ext [→2007] | Párraga Rodríguez (2018), *J. Macroeconomics* 56:340–360 | Banco de España **WP 1628**; SSRN 2883061; bde.es staff page |
| Spending | [1966–2008]+ext | Auerbach & Gorodnichenko (2012), "Measuring the output responses to fiscal policy," AEJ:EP | eml.berkeley.edu/~ygorodni (SPF forecast-error series) |

Notes: proxies are quarterly; align to the 1983Q1–2019Q4 grid and **set missing periods to 0**
(paper's convention). Transfers proxy is 0 for 2008–2019 even in the paper. Combine base+ext
for tax and transfers.

## Caveat — extended vs. base vintages
The paper's tax/transfer/spending proxies are the authors' versions extended to 2019Q4. Public
base series end earlier (tax ~2006, transfers 1991, spending ~2012). Two paths:
1. **Now:** use public base vintages (proxies zero outside coverage) → estimation runs on full
   sample; results should match the paper in shape. Good enough for the Track A sanity check.
2. **For exact match:** obtain the authors' extended proxies via the replication package
   (Andy contacting authors through supervisor). Swap in when available.
