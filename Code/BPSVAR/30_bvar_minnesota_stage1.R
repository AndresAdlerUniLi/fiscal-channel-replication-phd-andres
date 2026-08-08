# =====================================================================
# 30_bvar_minnesota_stage1.R   —  TRACK B, STAGE 1
# Reduced-form Bayesian VAR with a Minnesota prior (dummy-observation
# implementation, Bańbura–Giannone–Reichlin 2010) on the 8-variable
# baseline system. Produces posterior draws of (B, Sigma) that Stage 2
# (proxy/ARW structural identification) will consume.
#
# Input : Data_Processing/Final_VAR_Dataset/baseline_var_dataset_v2.csv
# Output: Outputs/VAR/stage1_bvar_posterior.rds   (list of draws + design)
# Spec  : quarterly 1983Q1–2019Q4, p = 4, log-levels x100 (paper Table A.1)
# Verified against a Python reference implementation (identical moments).
# =====================================================================
rm(list = ls())
setwd("/Users/andys/Desktop/University of Liechstenstein/The_Fiscal_Channels_of_Monetary _Policy/Fiscal_Channel_Replication/Fiscal_Channel_Replication")

## ---- 1. Data & settings --------------------------------------------
vars <- c("real_GDP","GDP_deflator","EBP","y1_yield","fiscal_deficit_ratio",
          "real_tax_revenues","real_transfers","real_gov_spending")
p       <- 4        # lags
lambda  <- 0.2      # Minnesota overall tightness
n_draws <- 2000     # posterior draws to store

d <- read.csv("Data_Processing/Final_VAR_Dataset/baseline_var_dataset_v2.csv")
Y <- as.matrix(d[, vars]); Tn <- nrow(Y); n <- length(vars)

## ---- 2. Design matrices (const + p lags) ---------------------------
Xlags <- do.call(cbind, lapply(1:p, function(i) Y[(p - i + 1):(Tn - i), ]))
X  <- cbind(1, Xlags)                      # (T-p) x (1+n*p)
Yd <- Y[(p + 1):Tn, ]
k  <- ncol(X)

## ---- 3. Minnesota prior via dummy observations ---------------------
# AR(1) residual std per variable (prior scale); delta = 1 => unit-root prior mean
s <- sapply(1:n, function(i){
  yi <- Y[, i]; fit <- lm(yi[-1] ~ yi[-length(yi)]); sd(resid(fit))
})
delta <- rep(1, n)

Jp   <- diag(1:p)
Yd_A <- rbind(diag(delta * s) / lambda, matrix(0, n * (p - 1), n))
Xd_A <- cbind(matrix(0, n * p, 1), kronecker(Jp, diag(s)) / lambda)
Yd_B <- diag(s);              Xd_B <- matrix(0, n, k)
Yd_C <- matrix(0, 1, n);      Xd_C <- matrix(0, 1, k); Xd_C[1, 1] <- 1e-4

Ystar <- rbind(Yd_A, Yd_B, Yd_C, Yd)
Xstar <- rbind(Xd_A, Xd_B, Xd_C, X)

## ---- 4. Posterior (Normal-inverse-Wishart) -------------------------
XtXinv <- solve(crossprod(Xstar))
Bhat   <- XtXinv %*% crossprod(Xstar, Ystar)     # k x n posterior mean
Estar  <- Ystar - Xstar %*% Bhat
Scale  <- crossprod(Estar)                       # IW scale (n x n)
nu     <- nrow(Ystar) - k                        # IW dof

## ---- 5. Helpers ----------------------------------------------------
companion_maxroot <- function(B){
  A <- matrix(0, n * p, n * p)
  A[1:n, ] <- do.call(cbind, lapply(1:p, function(i) t(B[(2 + (i - 1) * n):(1 + i * n), ])))
  if (p > 1) A[(n + 1):(n * p), 1:(n * (p - 1))] <- diag(n * (p - 1))
  max(Mod(eigen(A, only.values = TRUE)$values))
}
Lx <- t(chol(XtXinv))                            # lower factor of XtXinv

## ---- 6. Draw posterior ---------------------------------------------
set.seed(1)
B_draws   <- array(NA, c(k, n, n_draws))
Sig_draws <- array(NA, c(n, n, n_draws))
roots     <- numeric(n_draws)
for (m in 1:n_draws){
  Sig <- solve(stats::rWishart(1, nu, solve(Scale))[,,1])   # Sigma ~ IW(Scale, nu)
  Z   <- matrix(rnorm(k * n), k, n)
  B   <- Bhat + Lx %*% Z %*% chol(Sig)                       # B | Sigma ~ MN
  B_draws[,,m] <- B; Sig_draws[,,m] <- Sig; roots[m] <- companion_maxroot(B)
}

## ---- 7. Diagnostics & save -----------------------------------------
cat(sprintf("Sample: %s to %s | obs=%d, n=%d, p=%d, lambda=%.2f\n",
            d$date[p + 1], d$date[Tn], Tn - p, n, p, lambda))
cat(sprintf("Posterior-mean companion max root: %.4f\n", companion_maxroot(Bhat)))
cat(sprintf("Posterior max-root: median %.3f | share stable(<1): %.0f%%\n",
            median(roots), 100 * mean(roots < 1)))

dir.create("Outputs/VAR", recursive = TRUE, showWarnings = FALSE)
saveRDS(list(B_draws = B_draws, Sig_draws = Sig_draws, roots = roots,
             Bhat = Bhat, Scale = Scale, nu = nu, XtXinv = XtXinv,
             X = X, Y = Yd, vars = vars, p = p, lambda = lambda,
             dates = d$date[(p + 1):Tn]),
        "Outputs/VAR/stage1_bvar_posterior.rds")
cat("Saved posterior draws -> Outputs/VAR/stage1_bvar_posterior.rds  (feeds Stage 2)\n")
