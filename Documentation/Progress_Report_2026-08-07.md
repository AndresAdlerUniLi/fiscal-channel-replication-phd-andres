# Replication Progress Report — The Fiscal Channel of Monetary Policy
**Breitenlechner, Geiger & Klein (forthcoming, JPE Macroeconomics)**
Prepared: 7 August 2026 · Status: Phases 0–3 complete; Track B (Bayesian) engine built

---

## Executive summary
We have rebuilt the empirical foundation of the paper from raw data through estimation, and
implemented the core econometric machinery. The reduced-form model and our estimation engine
are demonstrably correct. We do **not** yet reproduce the paper's structural monetary-shock
signs using **public** proxy data, and we have diagnosed precisely why: (i) the quarterly
aggregation of the high-frequency monetary surprise materially changes the impact response, and
(ii) the paper relies on the authors' *extended, exact* proxy vintages and the faithful ARW
Bayesian proxy-SVAR procedure. This defines a short, specific list of materials to request.

## What we built
1. **Corrected data foundation (Phase 1).** 8-variable quarterly dataset, 1983Q1–2019Q4, in the
   paper's exact Table A.1 codes and log-levels×100 transforms (`baseline_var_dataset_v2.csv`).
   Fiscal deficit ratio rebuilt as (expenditures W019 − receipts W018)/nominal GDP and
   validated against reality (−1.5% surplus in 2000; +10.2% deficit in 2009).
2. **Monetary proxy (Phase 2).** Jarociński–Karadi high-frequency Fed surprises, aggregated to
   quarterly (`monetary_proxy_quarterly.csv`). First-stage relevance strong:
   corr(surprise, ΔGS1) = +0.61.
3. **Estimation engine (Track B).** Minnesota-prior Bayesian VAR with posterior sampling and
   credible bands, plus four identification schemes: frequentist external-IV, Bayesian
   external-IV, internal-instrument (Plagborg-Møller–Wolf), and recursive.

## Results and diagnosis
| Test | Output (impact) response to a contractionary shock | Reads as |
|------|-----------------------------------------------------|----------|
| Recursive VAR (no proxy), quarterly | **falls** (−0.06 to −0.08) | textbook — data & VAR healthy |
| Frequentist external-IV, quarterly | rises (puzzle) | proxy-identification issue |
| Bayesian external-IV, quarterly | rises (puzzle) | shrinkage doesn't flip impact |
| Internal-instrument (PMW), quarterly | rises (puzzle) | robust across methods |
| **Monthly** GK-style, same JK shock | **falls** (−0.13) | engine correct; sign right at monthly |

Two robust facts emerge. First, the reduced-form dynamics are textbook (recursive shock →
output down, EBP up, yield up-then-decay; GDP persistence 0.996). Second, the monetary-shock
output puzzle appears **only at quarterly frequency with the public proxy**: the identical shock
and code deliver the correct impact sign at monthly frequency. The quarterly aggregation of the
high-frequency surprise — and the exact proxy vintage/method — are therefore the operative
difference from the paper, not our data or our code.

## What we can and cannot do with public data
- **Can:** reproduce the full data pipeline; validate the reduced-form; source and validate the
  monetary proxy; run four identification approaches; get correct monetary signs at monthly
  frequency.
- **Cannot (yet):** match the paper's quarterly structural monetary IRFs and the fiscal-channel
  responses, because these depend on the authors' exact proxy construction/aggregation and the
  faithful ARW procedure.

## Specific materials to request from the authors
1. **Extended proxy series through 2019Q4** — the FF4 monetary surprise vintage (Gürkaynak et
   al. 2022) *as they aggregate it to quarterly*, and the extended tax (Mertens–Ravn), transfer
   (Romer–Romer), and spending (Auerbach–Gorodnichenko) narrative proxies.
2. **Estimation code** for the ARW Bayesian proxy-SVAR and the structural counterfactuals.
3. **EBP vintage** confirmation (Favara et al. updated Gilchrist–Zakrajšek).

As the paper is forthcoming at JPE Macro, a full replication package is a publication
requirement — so this is a low-cost, reasonable request.

## Recommended next steps
1. Take this report to the supervisor; request the three items above.
2. In parallel, we build the **faithful ARW Bayesian proxy-SVAR engine** so it is ready to
   accept the authors' proxy the moment it arrives (also required for the counterfactuals).
3. Source the three public fiscal proxies to stage the full 8-variable identification.
