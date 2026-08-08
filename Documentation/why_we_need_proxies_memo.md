# Memo — Why the Proxies Are Essential (for supervisor meeting)

**Project:** Replication of Breitenlechner, Geiger & Klein, *The Fiscal Channel of Monetary
Policy* (forthcoming, JPE Macroeconomics).
**Purpose:** Justify (a) why external-instrument proxies are indispensable to this replication,
and (b) the specific request to make to the authors.

## 1. Without proxies there is no causal result — only correlations
A reduced-form VAR produces residuals that are *mixtures* of all structural shocks. Impulse
responses from such residuals cannot be read causally. The paper's entire contribution is the
**structural identification** of (i) a monetary policy shock and (ii) three fiscal shocks (tax,
transfers, spending). The proxies are what turn reduced-form residuals into economically
interpretable shocks. Our current in-repo VAR (a recursive/Cholesky "EBP shock") is therefore a
pipeline test, not a replication.

## 2. Why not recursive (Cholesky) identification?
Recursive identification imposes contemporaneous timing/exclusion restrictions — e.g. that the
policy rate does not react to macro conditions within the quarter. In a quarterly macro system
that assumption is not credible (policy and the economy move together). The paper explicitly
rejects recursive timing in favour of **external instruments**.

## 3. What makes the proxies valid instruments
- **Monetary (FF4 high-frequency surprise):** interest-rate changes in a 30-minute window
  around FOMC announcements. Macro fundamentals cannot move within 30 minutes, so the surprise
  is plausibly exogenous — a valid instrument for the monetary shock.
- **Fiscal (narrative / forecast-error series):** legislated tax changes (Mertens–Ravn),
  Social-Security benefit changes (Romer–Romer), and government-spending forecast errors
  (Auerbach–Gorodnichenko) isolate fiscal changes *not* caused by current macro conditions.
- In the Bayesian proxy-SVAR (Arias–Rubio-Ramírez–Waggoner 2021) multiple proxies identify
  multiple shocks **simultaneously**, subject to a relevance condition (each shock explains
  ≥10% of its proxy's variance) and exogeneity.

## 4. The proxies are literally what the counterfactuals switch off
The paper's headline result — that fiscal responses reshape monetary transmission — is built by
constructing counterfactuals that **neutralise the fiscal shocks** (set tax/transfer/spending
responses to zero). If we have no fiscal proxies, we identify no fiscal shocks, and there is
**nothing to switch off** — i.e. no fiscal-channel result at all. So the fiscal proxies are not
optional add-ons; they are the mechanism of the paper.

## 5. Base vs. extended vintages — the specific ask
Public base proxy vintages end early (tax ~2006, transfers 1991, spending ~2012). The paper
uses the authors' versions **extended to 2019Q4**. We can run the sanity-check estimation now
with base vintages (proxy = 0 outside its coverage), but an **exact** match to the published
numbers requires the extended series.

**Request to make to the authors (via supervisor introduction):**
1. Their **extended proxy series** through 2019Q4 (tax, transfers, spending) and the exact
   **FF4 monetary surprise** vintage (Gürkaynak et al. 2022) they used.
2. Their **estimation code** for the ARW Bayesian proxy-SVAR and the counterfactuals (for
   cross-checking our R implementation).
3. Confirmation of the **EBP vintage** (Favara et al. updated Gilchrist–Zakrajšek series).

Since the paper is forthcoming at JPE Macro, a full replication package is a condition of
publication — so this is a reasonable and low-cost request.
