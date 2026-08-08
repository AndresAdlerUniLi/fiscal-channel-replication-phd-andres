# =====================================================================
# 31_proxy_identification_stage2.R   —  TRACK B, STAGE 2
# Structural identification of 4 shocks (monetary, tax, transfer,
# spending) via external-instrument proxies, ARW-style, on top of the
# Stage-1 reduced-form posterior draws.
#
# Identification (per posterior draw of B, Sigma):
#   u_t     = reduced-form residuals
#   Smu     = (1/T) sum_t (m_t - mbar) u_t'          (k x n)
#   Psi     = Smu Sigma^{-1} Smu'                     (k x k)
#   V       = chol(Psi)  (Psi = V V'; triangular V => ARW ordering)
#   Theta1  = Smu' (V')^{-1}                          (n x k) impact of the k shocks
#   IRF_h   = Companion_h %*% Theta1
# Relevance (ARW threshold 0.10): diag(Psi)/diag(cov(m)).
#
# Input : Outputs/VAR/stage1_bvar_posterior.rds  (run 30_... first)
#         Data_Processing/Cleaned_Data/{monetary,tax,transfer,spending}_*.csv
# Output: Outputs/VAR/stage2_irf.rds ; Outputs/IRFs/stage2_monetary_irf.png
# Verified against a Python reference implementation.
# =====================================================================
rm(list = ls())
setwd("/Users/andys/Desktop/University of Liechstenstein/The_Fiscal_Channels_of_Monetary _Policy/Fiscal_Channel_Replication/Fiscal_Channel_Replication")

st <- readRDS("Outputs/VAR/stage1_bvar_posterior.rds")
B_draws <- st$B_draws; Sig_draws <- st$Sig_draws
X <- st$X; Yd <- st$Y; vars <- st$vars; p <- st$p; n <- length(vars)
dates <- as.Date(st$dates); H <- 20; nd <- dim(B_draws)[3]

## ---- proxies aligned to residual sample; ORDER: monetary,tax,transfer,spending ----
getpx <- function(f, c){
  z <- read.csv(file.path("Data_Processing/Cleaned_Data", f)); z$date <- as.Date(z$date)
  z[[c]][match(dates, z$date)] |> (\(x){ x[is.na(x)] <- 0; x })()
}
M <- cbind(getpx("monetary_proxy_timed_quarterly.csv","mp_median_timed"),   # timing-weighted (Exp 1b)
           getpx("tax_proxy_extended_quarterly.csv","tax_HHP"),
           getpx("transfer_proxy_quarterly_extended.csv","transfer_RR_ext"),
           getpx("spending_proxy_quarterly.csv","spend_FE"))
kx <- ncol(M); SHK <- c("Monetary","Tax","Transfer","Spending")
own <- c(Monetary="y1_yield", Tax="real_tax_revenues",
         Transfer="real_transfers", Spending="real_gov_spending")
Mc <- scale(M, center = TRUE, scale = FALSE)

companion_irf <- function(B){
  A <- lapply(1:p, function(i) t(B[(2+(i-1)*n):(1+i*n), ]))
  Phi <- vector("list", H+1); Phi[[1]] <- diag(n)
  for (h in 1:H){ S <- matrix(0,n,n); for (i in 1:p) if (h-i>=0) S <- S + A[[i]] %*% Phi[[h-i+1]]; Phi[[h+1]] <- S }
  Phi
}

IRF <- array(NA, c(nd, H+1, n, kx)); REL <- matrix(NA, nd, kx)
for (m in 1:nd){
  B <- B_draws[,,m]; Sig <- Sig_draws[,,m]
  u <- Yd - X %*% B
  Smu <- crossprod(Mc, u) / nrow(u)                 # k x n
  Psi <- Smu %*% solve(Sig) %*% t(Smu)              # k x k
  Vv  <- tryCatch(t(chol(Psi)), error=function(e) NULL); if (is.null(Vv)) next   # Psi = Vv Vv'
  Th1 <- t(Smu) %*% solve(t(Vv))                    # n x k
  for (j in 1:kx){ oi <- match(own[SHK[j]], vars); if (Th1[oi,j] < 0) Th1[,j] <- -Th1[,j] }
  Th1[,1] <- Th1[,1] * (0.25 / Th1[match("y1_yield",vars),1])   # monetary: +25bp on yield
  Phi <- companion_irf(B)
  IRF[m,,,] <- aperm(simplify2array(lapply(0:H, function(h) Phi[[h+1]] %*% Th1)), c(3,1,2))
  REL[m,] <- diag(Psi) / diag(crossprod(Mc)/nrow(u))
}
med <- apply(IRF, c(2,3,4), median, na.rm=TRUE)
saveRDS(list(IRF=IRF, REL=REL, vars=vars, shocks=SHK, H=H), "Outputs/VAR/stage2_irf.rds")

cat("Relevance (share of proxy var explained; ARW threshold 0.10):\n  ")
cat(paste(sprintf("%s=%.2f", SHK, apply(REL,2,median,na.rm=TRUE)), collapse=" | "), "\n")

## ---- figure: monetary shock, 8 panels, 68% bands ----
lo <- apply(IRF, c(2,3,4), quantile, .16, na.rm=TRUE); hi <- apply(IRF, c(2,3,4), quantile, .84, na.rm=TRUE)
png("Outputs/IRFs/stage2_monetary_irf.png", width=1400, height=650); par(mfrow=c(2,4))
for (i in 1:n){
  plot(0:H, med[,i,1], type="l", lwd=2, col="#08306b", ylim=range(lo[,i,1],hi[,i,1]),
       main=vars[i], xlab="Quarters", ylab="")
  polygon(c(0:H,H:0), c(lo[,i,1],rev(hi[,i,1])), col="#9ecae133", border=NA)
  lines(0:H, med[,i,1], lwd=2, col="#08306b"); abline(h=0)
}
dev.off()
cat("Saved Outputs/VAR/stage2_irf.rds and Outputs/IRFs/stage2_monetary_irf.png\n")
