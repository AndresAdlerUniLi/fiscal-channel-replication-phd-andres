# Data & Code Request — DRAFT (for supervisor review before sending)

Two pieces below: (A) a short cover note for the supervisor, and (B) a draft email to the
authors. Both are deliberately specific and acknowledge the work already done, so the ask is
small and easy to grant.

---

## A. Cover note for supervisor

I've independently reproduced the *qualitative* results of Breitenlechner, Geiger & Klein
("The Fiscal Channel of Monetary Policy," forthcoming JPE Macro) from public data — including
building the full Bayesian proxy-SVAR and the structural counterfactuals, and diagnosing/fixing a
temporal-aggregation problem in the monetary instrument. The fiscal channel comes through: a
contractionary monetary shock lowers output and prices, the deficit rises, taxes fall, transfers
rise, and the counterfactuals show fiscal responses cushion the transmission.

To move from a qualitative match to the paper's exact magnitudes, I need a small, specific set of
their materials (below). Since the paper is forthcoming at JPE Macro — which requires a deposited
replication package — this should be a low-cost request. Could you make the introduction / forward
the note in (B)?

---

## B. Draft email to the authors

Subject: Replication of "The Fiscal Channel of Monetary Policy" — a small data/code request

Dear Professors Breitenlechner, Geiger, and Klein,

I am a graduate researcher at the University of Liechtenstein working, under the supervision of
[supervisor name], on a careful replication of "The Fiscal Channel of Monetary Policy." I have
reconstructed the full empirical pipeline from public sources — the FRED variable set (Table A.1),
the excess bond premium, and the four identification proxies — and implemented the Bayesian
proxy-SVAR and the structural counterfactuals. I am able to reproduce your central results
qualitatively: a contractionary monetary shock lowers output and prices and induces a pronounced
fiscal adjustment (deficit up, tax revenues down, transfers up), and the counterfactuals show the
fiscal response shapes the transmission to output and prices.

To match your published magnitudes precisely, I would be very grateful for the following, in
whatever form is convenient:

1. **The monetary policy surprise series** — your FF4 (three-month-ahead fed funds future)
   surprises from Gürkaynak et al. (2022), and in particular **how you aggregate them to the
   quarterly frequency** (a script or a short description). In my own work the aggregation rule
   turned out to matter substantially for the sign of the output response, so this is the single
   most valuable item.
2. **The extended fiscal proxies** through 2019Q4 — the tax (Mertens–Ravn, extended),
   transfer (Romer–Romer, extended), and government-spending forecast-error series as you use them.
3. **The estimation and counterfactual code** (the Arias–Rubio-Ramírez–Waggoner BPSVAR and the
   counterfactual construction), for cross-checking my implementation.
4. Confirmation that the EBP is the Favara et al. (2016) updated Gilchrist–Zakrajšek series
   (I believe it is).

I'm happy to share my replication materials and to acknowledge your assistance in any resulting
work. Thank you very much for considering this — and for a paper that has been a pleasure to work
through.

With thanks and best regards,
[Andy — full name, affiliation]

---

## C. Our swap-in plan (so their proxy → exact match is a 5-minute job)

When their FF4 quarterly series arrives, drop it in `Data_Processing/Cleaned_Data/` and point the
Stage-2 / Stage-3 scripts' monetary column at it (one line, as we did for `mp_median_timed`).
Everything downstream — identification, IRFs, counterfactuals — regenerates unchanged. If they
send announcement-level FF4, `33_exp1b_exactdate_timing.R` already implements the exact-date
timing aggregation to convert it.
