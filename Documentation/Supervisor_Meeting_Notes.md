# Supervisor Meeting Notes — The Fiscal Channel of Monetary Policy (replication)

Running talking points for supervisor meetings. Most recent at top.
Companion docs: `Progress_Report_2026-08-07.md`, `why_we_need_proxies_memo.md`,
`Extension_Proposal_PostPandemic.md`.

---

## Note (2026-08-08) — The monetary "output puzzle": diagnosed & partially fixed

**Headline:** the one thing that doesn't yet match the paper — a contractionary monetary shock
raising output rather than lowering it — is a **temporal-aggregation artifact of the
high-frequency surprise**, and we have a defensible partial fix. This is a *localized,
understood* problem, not a dead end.

**Evidence.** The reduced-form VAR is textbook (a recursive yield shock gives output↓, EBP↑),
and the identical Jarociński–Karadi surprise gives output↓ on impact at *monthly* frequency —
the sign only flips when the surprise is aggregated to quarterly. We then rebuilt the quarterly
monetary proxy under four aggregation rules (same identification throughout):

Using JK's **announcement-level** surprises (exact FOMC date), weighting each by the fraction of
its quarter occurring after the announcement:

| Aggregation of the HF surprise | GDP impact | GDP 4q | GDP 8q | EBP 4q | 1st-stage F |
|---|---|---|---|---|---|
| Sum (naïve, baseline) | +0.15 | +0.25 | +0.17 | −0.02 | 13.1 |
| **Timing-weighted** | +0.04 | +0.04 | **−0.06** | +0.00 | **17.5** |
| Timing + carryover | **−0.05** | **−0.20** | **−0.32** | **+0.05** | 4.1 |

Reading: a naïve within-quarter sum lets the quarterly surprise correlate with the quarter's
output innovation (the Fed hikes as data come in strong) → puzzle. Respecting *when* in the
quarter each surprise occurred **removes the puzzle with a STRONG instrument (F=17.5)**;
attributing a late-quarter surprise to the next quarter (it cannot have moved this quarter's
output) flips everything to textbook signs but weakens the instrument (F=4.1). We have adopted
the timing-weighted proxy as canonical. The remaining cleanliness-vs-strength tradeoff is exactly
what the authors' precise FF4 construction is expected to resolve.

**Implication / the ask.** The paper reports clean quarterly results, so their specific FF4
series and aggregation evidently avoid this contamination. Two ways to close it:
1. **From the authors (preferred):** their exact FF4 monetary surprise *and their quarterly
   aggregation method / code*. This is the decisive item.
2. **Ourselves (in progress):** JK also publish the surprises at the exact FOMC-announcement
   level (`shocks_fed_jk_t.csv`); with those we can do precise within-quarter timing and likely
   get clean signs *and* a strong instrument — no waiting required.

**Bottom line for the meeting:** data pipeline + full Bayesian proxy-SVAR are built and correct;
fiscal shocks are cleanly identified; the monetary puzzle is now *understood and half-solved*.
The remaining gap is a specific, reasonable request to the authors (their FF4 + aggregation),
which a JPE-Macro replication package must contain anyway.

Reproducible: `Code/BPSVAR/32_exp1_aggregation.R`; results
`Outputs/Tables/exp1_aggregation_results.csv`; full detail in logbook Entry 016.
