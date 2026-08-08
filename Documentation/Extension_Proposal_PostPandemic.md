# Extension Proposal — The Fiscal Channel of Monetary Policy in the Post-Pandemic Era
**Building on Breitenlechner, Geiger & Klein (forthcoming, JPE Macroeconomics)**
Prepared: 7 August 2026 · Status: proposal for discussion (extension, *not* replication)

---

## 1. Motivation
The original paper deliberately ends its sample in 2019Q4 to avoid the COVID-19 turbulence.
That leaves the entire 2020–2025 period — arguably the most fiscally and monetarily eventful
stretch since the early 1980s — unexamined by a framework purpose-built to study exactly these
interactions. The post-pandemic era is close to an ideal testing ground for the fiscal channel:

- **Interest-payment mechanism at scale.** The paper's signature mechanism is that total
  government expenditures include interest payments, so a monetary tightening mechanically
  raises fiscal outlays. During the 2022–2023 tightening cycle — the fastest since Volcker — US
  federal net interest outlays roughly doubled. The paper's central mechanism appears in the
  data at unusually large magnitude.
- **Transfer margin.** 2020–2021 saw an extraordinary transfer surge (economic impact payments,
  expanded unemployment insurance), directly on the second fiscal margin the paper studies.
- **Salient monetary–fiscal interaction.** Debates over fiscal dominance, deficit financing, and
  the fiscal costs of disinflation were front-and-centre for policymakers throughout 2021–2025.

As a distinct contribution — a second paper or dissertation chapter — a natural title is
*"The Fiscal Channel of Monetary Policy Through the Post-Pandemic Tightening Cycle."*

## 2. Research questions
1. Does the endogenous fiscal response to monetary shocks (deficit ↑, transfers ↑, tax revenue ↓)
   documented for 1983–2019 persist, strengthen, or weaken in 2020–2025?
2. Given historically high debt and rates, is the interest-payment component of the fiscal
   channel quantitatively larger post-2020?
3. Do the paper's structural counterfactuals — the share of the price/output response shaped by
   fiscal adjustment — change in the post-pandemic regime?

## 3. Methodological hurdles (the reasons this is an extension, not a sample tweak)
1. **COVID outliers break a linear Gaussian VAR.** 2020Q2 is a ~30%-annualised output collapse
   followed by an equally violent rebound; four quarters can dominate the likelihood and
   destabilise estimates. This is precisely why the authors excluded COVID.
   *Fix:* Lenza & Primiceri (2022, JAE), *"How to estimate a VAR after March 2020"* — rescale
   the pandemic-era residual volatility; or explicit outlier/dummy treatment; or stochastic-
   volatility / fat-tailed errors (Carriero et al. 2022).
2. **Instrument relevance collapses at the ZLB (2020–2021).** The baseline FF4 surprise is
   near-zero when policy moves through QE and forward guidance rather than the funds rate, so the
   monetary instrument goes weak exactly in this window.
   *Fix:* supplement/replace with Swanson (2021) forward-guidance and LSAP factors; or restrict
   the tightening-cycle analysis to 2022 onward when the funds rate is again the active margin.
3. **Fiscal proxies lose exogeneity in the pandemic.** The 2020–2021 fiscal packages (CARES Act
   transfers, etc.) were direct responses to the COVID shock, not exogenous legislated changes —
   violating the exogeneity condition underpinning the narrative proxy identification.
   *Fix:* down-weight/exclude pandemic fiscal proxies; rely on the automatic-stabiliser channel
   (deficit/tax/transfer *responses*) rather than identified fiscal *shocks* in that window.
4. **Parameter stability.** A constant-coefficient VAR over 1983–2025 splices the Great
   Moderation, the ZLB decade, and the 2022 inflation spike into one regime.
   *Fix:* subsample or time-varying-parameter estimation; or a focused shorter window.

## 4. Candidate designs (in order of preference)
- **(A) Focused tightening-cycle study, ~2010–2025.** Centre on 2022–2023; COVID-robust
  volatility (Lenza–Primiceri); funds-rate-based surprises reactivated post-2021. Cleanest and
  most defensible; foregrounds the interest-payment mechanism.
- **(B) Full-sample 1983–2025 with pandemic-robust errors.** Maximises data but leans hardest on
  the volatility correction and the stability assumption; best as a robustness companion to (A).
- **(C) Regime comparison.** Estimate 1983–2019 (the replication) vs. 2010/2015–2025 and compare
  IRFs/counterfactuals directly — cleanly separates "has the fiscal channel changed?".

## 5. Data required beyond the replication set
- Extend all 8 baseline FRED series through 2025 (already downloaded to 2025Q4 in `Raw_Data`).
- Monetary instruments extended: JK surprises already run to 2026 in the archived file; add
  Swanson (2021) FG/LSAP factors for the ZLB window.
- Fiscal proxies extended and flagged for pandemic-era exogeneity concerns.
- Optional added variables for the period: an energy/commodity price or supply-shock control
  (Russia–Ukraine 2022 energy shock) if the analysis conditions on supply disturbances.

## 6. Positioning relative to the replication
Keep the two strictly separate, consistent with the project philosophy:
- **Replication (1983–2019):** establishes credibility; reproduces the published results.
- **Extension (2020/2010–2025):** a new contribution answering whether the fiscal channel holds
  in the post-pandemic regime. The reusable pipeline built for the replication is designed to
  support exactly this.

## 7. Key references
- Breitenlechner, Geiger & Klein (forthcoming), *The Fiscal Channel of Monetary Policy.*
- Lenza & Primiceri (2022), *How to estimate a VAR after March 2020*, J. Applied Econometrics.
- Swanson (2021), *Measuring the effects of Fed forward guidance and asset purchases*, JME.
- Arias, Rubio-Ramírez & Waggoner (2021), *Inference in Bayesian Proxy-SVARs*, J. Econometrics.
- Carriero, Clark, Marcellino & Mertens (2022), pandemic-era BVAR volatility.
