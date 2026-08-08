# =====================================================================
# 34_counterfactuals_stage3.R   —  TRACK B, STAGE 3
# Structural counterfactuals (the paper's headline). After a monetary
# shock, feed OFFSETTING fiscal shocks that hold a chosen fiscal
# variable's response at zero, then read how output & prices would have
# moved absent that fiscal margin. Gap = the fiscal channel's contribution.
#
# Method (per posterior draw): identify Theta (n x 4) as in Stage 2, then
#   baseline: y_h = Phi_h theta_m
#   shut var v via shock f: solve eps_s (s<=h) s.t. v's response = 0 each h
#     eps_h = -(y^base_{v,h} + sum_{s<h} a_{h-s} eps_s)/a_0 , a_j=(Phi_j theta_f)_v
#   counterfactual path: y_h + sum_s Phi_{h-s} theta_f eps_s
#   joint (all 3 fiscal): 3x3 system on the 3 fiscal rows each horizon.
#
# Input : Outputs/VAR/stage1_bvar_posterior.rds  + proxies (timed monetary)
# Output: Outputs/VAR/stage3_counterfactuals.rds ; Outputs/IRFs/stage3_counterfactuals.png ;
#         Outputs/Tables/stage3_counterfactual_summary.csv
# Verified against a Python reference.
# =====================================================================
rm(list=ls())
setwd("/Users/andys/Desktop/University of Liechstenstein/The_Fiscal_Channels_of_Monetary _Policy/Fiscal_Channel_Replication/Fiscal_Channel_Replication")
st<-readRDS("Outputs/VAR/stage1_bvar_posterior.rds")
B_draws<-st$B_draws;Sig_draws<-st$Sig_draws;X<-st$X;Yd<-st$Y;vars<-st$vars;p<-st$p;n<-length(vars)
dates<-as.Date(st$dates);H<-20;nd<-dim(B_draws)[3]
getpx<-function(f,c){z<-read.csv(file.path("Data_Processing/Cleaned_Data",f));z$date<-as.Date(z$date)
  x<-z[[c]][match(dates,z$date)];x[is.na(x)]<-0;x}
M<-cbind(getpx("monetary_proxy_timed_quarterly.csv","mp_median_timed"),
         getpx("tax_proxy_extended_quarterly.csv","tax_HHP"),
         getpx("transfer_proxy_quarterly_extended.csv","transfer_RR_ext"),
         getpx("spending_proxy_quarterly.csv","spend_FE")); Mc<-scale(M,TRUE,FALSE)
GDP<-1;DEFL<-2;FV<-c(6,7,8)                    # real_tax_rev, real_transfers, real_gov_spend rows
ownS<-list(no_tax=c(6,2),no_transfer=c(7,3),no_spending=c(8,4))  # (var row, shock col)
companion<-function(B){A<-lapply(1:p,function(i) t(B[(2+(i-1)*n):(1+i*n),]));Phi<-vector("list",H+1);Phi[[1]]<-diag(n)
  for(h in 1:H){S<-matrix(0,n,n);for(i in 1:p) if(h-i>=0) S<-S+A[[i]]%*%Phi[[h-i+1]];Phi[[h+1]]<-S};Phi}
scen<-c("baseline","no_tax","no_transfer","no_spending","no_fiscal")
OUT<-lapply(scen,function(x) matrix(NA,nd,H+1)); PRC<-lapply(scen,function(x) matrix(NA,nd,H+1)); names(OUT)<-names(PRC)<-scen
for(m in 1:nd){
  B<-B_draws[,,m];Sig<-Sig_draws[,,m];u<-Yd-X%*%B
  Smu<-crossprod(Mc,u)/nrow(u);Psi<-Smu%*%solve(Sig)%*%t(Smu)
  Vv<-tryCatch(t(chol(Psi)),error=function(e)NULL);if(is.null(Vv))next
  Th<-t(Smu)%*%solve(t(Vv))
  for(j in 1:4){vv<-c(4,6,7,8)[j];if(Th[vv,j]<0)Th[,j]<--Th[,j]}
  Th[,1]<-Th[,1]*(0.25/Th[4,1])
  Phi<-companion(B);thm<-Th[,1];yb<-t(sapply(0:H,function(h)Phi[[h+1]]%*%thm))
  OUT$baseline[m,]<-yb[,GDP];PRC$baseline[m,]<-yb[,DEFL]
  for(nm in names(ownS)){vidx<-ownS[[nm]][1];thf<-Th[,ownS[[nm]][2]]
    a<-sapply(0:H,function(j)(Phi[[j+1]]%*%thf)[vidx]);eps<-numeric(H+1)
    for(h in 0:H){pr<-if(h>0)sum(sapply(0:(h-1),function(t)a[h-t+1]*eps[t+1])) else 0;eps[h+1]<--(yb[h+1,vidx]+pr)/a[1]}
    yc<-yb;for(h in 0:H){yc[h+1,]<-yb[h+1,]+rowSums(sapply(0:h,function(t)Phi[[h-t+1]]%*%thf*eps[t+1]))}
    OUT[[nm]][m,]<-yc[,GDP];PRC[[nm]][m,]<-yc[,DEFL]}
  Fm<-Th[,c(2,3,4)];A0<-Fm[FV,];epsv<-matrix(0,H+1,3);yc<-yb
  for(h in 0:H){pr<-if(h>0)rowSums(sapply(0:(h-1),function(t)Phi[[h-t+1]]%*%Fm%*%epsv[t+1,])) else rep(0,n)
    epsv[h+1,]<-solve(A0,-(yb[h+1,FV]+pr[FV]))
    yc[h+1,]<-yb[h+1,]+rowSums(sapply(0:h,function(t)Phi[[h-t+1]]%*%Fm%*%epsv[t+1,]))}
  OUT$no_fiscal[m,]<-yc[,GDP];PRC$no_fiscal[m,]<-yc[,DEFL]
}
med<-function(a)apply(a,2,median,na.rm=TRUE)
saveRDS(list(OUT=OUT,PRC=PRC),"Outputs/VAR/stage3_counterfactuals.rds")
summ<-data.frame(scenario=scen,
  GDP_q20=sapply(scen,function(s)round(med(OUT[[s]])[21],3)),
  DEFL_q20=sapply(scen,function(s)round(med(PRC[[s]])[21],3)))
dir.create("Outputs/Tables",showWarnings=FALSE);write.csv(summ,"Outputs/Tables/stage3_counterfactual_summary.csv",row.names=FALSE)
print(summ)
cols<-c(baseline="black",no_tax="#d94801",no_transfer="#2171b5",no_spending="#238b45",no_fiscal="#6a51a3")
png("Outputs/IRFs/stage3_counterfactuals.png",width=1300,height=520);par(mfrow=c(1,2))
for(pan in list(list(OUT,"Real GDP (%)"),list(PRC,"GDP deflator (%)"))){
  L<-pan[[1]];rng<-range(sapply(scen,function(s)med(L[[s]])))
  plot(0:H,med(L$baseline),type="l",lwd=3,ylim=rng,main=pan[[2]],xlab="Quarters",ylab="")
  for(s in scen)lines(0:H,med(L[[s]]),col=cols[s],lwd=ifelse(s%in%c("baseline","no_fiscal"),3,1.5),lty=ifelse(s%in%c("baseline","no_fiscal"),1,2))
  abline(h=0)}
legend("bottomleft",legend=scen,col=cols,lwd=2,lty=c(1,2,2,2,1),cex=.8);dev.off()
cat("Saved counterfactual outputs + figure + summary table.\n")
