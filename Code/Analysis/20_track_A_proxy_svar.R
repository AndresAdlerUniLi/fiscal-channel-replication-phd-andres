# =====================================================================
# 20_track_A_proxy_svar.R
# Track A — frequentist proxy-SVAR sanity check (Gertler-Karadi style
# external-instrument identification) on the small 4-variable system.
# Compares proxy-IV identification vs recursive (Cholesky).
# Input : Data_Processing/Final_VAR_Dataset/baseline_var_dataset_v2.csv
#         Data_Processing/Cleaned_Data/monetary_proxy_quarterly.csv
# Output: Outputs/IRFs/track_A_monetary_irf.{png,csv}
# =====================================================================
rm(list=ls())
# --- set working directory to the project root (folder containing Code/, Data_Processing/, Outputs/) ---
setwd("/Users/andys/Desktop/University of Liechstenstein/The_Fiscal_Channels_of_Monetary _Policy/Fiscal_Channel_Replication/Fiscal_Channel_Replication")

vars <- c("real_GDP","GDP_deflator","EBP","y1_yield"); POL <- 4
p <- 4; H <- 20; START <- as.Date("1990-01-01")

b  <- read.csv("Data_Processing/Final_VAR_Dataset/baseline_var_dataset_v2.csv")
mp <- read.csv("Data_Processing/Cleaned_Data/monetary_proxy_quarterly.csv")
b$date <- as.Date(b$date); mp$date <- as.Date(mp$date)
d  <- merge(b, mp[,c("date","mp_median")], by="date")
d  <- d[d$date>=START,]; Y <- as.matrix(d[,vars]); m <- d$mp_median

fit_var <- function(Y,p){
  T <- nrow(Y); X <- cbind(1, do.call(cbind, lapply(1:p, function(i) Y[(p-i+1):(T-i),])))
  Yd <- Y[(p+1):T,]; B <- solve(t(X)%*%X, t(X)%*%Yd); list(B=B, U=Yd-X%*%B)
}
comp_irf <- function(B,p,n,H){
  A <- lapply(1:p, function(i) t(B[(2+(i-1)*n):(1+i*n),]))
  Phi <- list(diag(n))
  for(h in 1:H){ S <- matrix(0,n,n); for(i in 1:p) if(h-i>=0) S <- S + A[[i]]%*%Phi[[h-i+1]]; Phi[[h+1]] <- S }
  Phi
}
impact_iv <- function(U,m,pol){ mc<-m-mean(m); cov<-colMeans(mc*sweep(U,2,colMeans(U))); cov/cov[pol] }

n <- length(vars); f <- fit_var(Y,p); U <- f$U; m_r <- m[(p+1):length(m)]
Phi <- comp_irf(f$B,p,n,H)
s_iv <- 0.25*impact_iv(U,m_r,POL)                 # +25bp on yield
irf_iv <- t(sapply(0:H, function(h) Phi[[h+1]]%*%s_iv))
P  <- t(chol(cov(U))); s_ch <- P[,POL]/P[POL,POL]*0.25
irf_ch <- t(sapply(0:H, function(h) Phi[[h+1]]%*%s_ch))

png("Outputs/IRFs/track_A_monetary_irf.png", width=1000, height=720)
par(mfrow=c(2,2))
lab <- c("Real GDP (%)","GDP deflator (%)","Excess bond premium (pp)","1-year yield (pp)")
for(j in 1:n){
  plot(0:H, irf_iv[,j], type="l", lwd=2, col="#08519c", xlab="Quarters", ylab="", main=lab[j],
       ylim=range(irf_iv[,j],irf_ch[,j]))
  lines(0:H, irf_ch[,j], lwd=2, lty=2, col="#d94801"); abline(h=0)
}
dev.off()
write.csv(data.frame(h=0:H, setNames(as.data.frame(irf_iv),paste0(vars,"_ivproxy")),
                     setNames(as.data.frame(irf_ch),paste0(vars,"_cholesky"))),
          "Outputs/IRFs/track_A_monetary_irf.csv", row.names=FALSE)
cat("Track A done. Verdict: recursive VAR textbook; proxy-IV shows short-horizon\n",
    "output puzzle (weak instrument, quarterly) -> proceed to Bayesian Track B.\n")