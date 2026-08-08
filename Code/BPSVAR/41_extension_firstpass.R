# =====================================================================
# 41_extension_firstpass.R  —  POST-PANDEMIC EXTENSION (exploratory)
# First-pass: extend the sample to 2025 and compare the monetary-shock
# responses to the 1983-2019 baseline. COVID quarters (2020Q2-Q4) enter
# as exogenous dummies. External-IV (timing-weighted MP_median).
# EXPLORATORY — heavy caveats (see Extension_Proposal_PostPandemic.md):
#   * monetary instrument weak at the 2020-21 ZLB
#   * COVID dummies are a crude fix (cf. Lenza-Primiceri 2022 volatility)
#   * fiscal narrative proxies NOT extended -> no extended counterfactuals
# Inputs (built by ext_build): var_dataset_extended_2025.csv,
#   monetary_proxy_timed_extended.csv ; baseline_var_dataset_v2.csv,
#   monetary_proxy_timed_quarterly.csv
# Output: Outputs/Figures/ext_monetary_baseline_vs_2025.{png,pdf}
# =====================================================================
rm(list=ls())
setwd("/Users/andys/Desktop/University of Liechstenstein/The_Fiscal_Channels_of_Monetary _Policy/Fiscal_Channel_Replication/Fiscal_Channel_Replication")
V<-c("real_GDP","GDP_deflator","EBP","y1_yield","fiscal_deficit_ratio","real_tax_revenues","real_transfers","real_gov_spending")
p<-4;lam<-0.2;H<-20
fitIRF<-function(dfile,pfile,pcol,covid=FALSE){
  d<-read.csv(dfile);d$date<-as.Date(d$date);Y<-as.matrix(d[,V]);Tn<-nrow(Y);n<-length(V);rd<-d$date[(p+1):Tn]
  X<-cbind(1,do.call(cbind,lapply(1:p,function(i) Y[(p-i+1):(Tn-i),])))
  if(covid){for(q in c("2020-04-01","2020-07-01","2020-10-01")){D<-as.integer(rd==as.Date(q));X<-cbind(X,D)}}
  Yd<-Y[(p+1):Tn,];k<-ncol(X)
  s<-sapply(1:n,function(i){yi<-Y[,i];sd(resid(lm(yi[-1]~yi[-length(yi)])))})
  Yd_A<-rbind(diag(s)/lam,matrix(0,n*(p-1),n));Xd_A<-cbind(matrix(0,n*p,1),kronecker(diag(1:p),diag(s))/lam,matrix(0,n*p,k-1-n*p))
  loose<-c(1,(2+n*p):k);Xd_C<-matrix(0,length(loose),k);for(r in seq_along(loose))Xd_C[r,loose[r]]<-1e-4
  B<-solve(crossprod(rbind(Xd_A,matrix(0,n,k),Xd_C,X)),crossprod(rbind(Xd_A,matrix(0,n,k),Xd_C,X),rbind(Yd_A,diag(s),matrix(0,length(loose),n),Yd)))
  u<-Yd-X%*%B;A<-lapply(1:p,function(i) t(B[(2+(i-1)*n):(1+i*n),]));Phi<-list(diag(n))
  for(h in 1:H){S<-matrix(0,n,n);for(i in 1:p) if(h-i>=0) S<-S+A[[i]]%*%Phi[[h-i+1]];Phi[[h+1]]<-S}
  mdf<-read.csv(pfile);mdf[,1]<-as.Date(mdf[,1]);m<-mdf[[pcol]][match(rd,mdf[,1])];m[is.na(m)]<-0
  mc<-m-mean(m);cov<-colMeans(mc*sweep(u,2,colMeans(u)));simp<-0.25*cov/cov[4]
  t(sapply(0:H,function(h) Phi[[h+1]]%*%simp))
}
base<-fitIRF("Data_Processing/Final_VAR_Dataset/baseline_var_dataset_v2.csv","Data_Processing/Cleaned_Data/monetary_proxy_timed_quarterly.csv","mp_median_timed",FALSE)
ext <-fitIRF("Data_Processing/Final_VAR_Dataset/var_dataset_extended_2025.csv","Data_Processing/Cleaned_Data/monetary_proxy_timed_extended.csv","mp_median_timed",TRUE)
TIT<-c("Output","Prices (deflator)","Excess bond premium","One-year rate","Fiscal deficit","Tax revenues","Transfers","Government spending")
drawf<-function(){par(mfrow=c(2,4),mar=c(3.2,3.4,2,0.6),mgp=c(2,.6,0),family="serif")
  for(i in 1:8){yl<-range(base[,i],ext[,i]);plot(0:H,base[,i],type="l",col="#888",lwd=2,lty=2,ylim=yl,main=TIT[i],xlab=ifelse(i>4,"Quarters",""),ylab="")
    lines(0:H,ext[,i],col="#7a1f1f",lwd=2);abline(h=0,col="#444",lty=3)}
  legend("topright",legend=c("Baseline 1983-2019","Extended 1983-2025"),col=c("#888","#7a1f1f"),lty=c(2,1),lwd=2,bty="n",cex=.7)
  mtext("Extension (exploratory): monetary-shock responses, baseline vs extended through 2025",outer=TRUE,line=-1.2,cex=.9,family="serif")}
png("Outputs/Figures/ext_monetary_baseline_vs_2025.png",width=1500,height=760,res=140);drawf();dev.off()
pdf("Outputs/Figures/ext_monetary_baseline_vs_2025.pdf",width=12,height=5.6);drawf();dev.off()
cat("Extension figure saved. Fiscal channel (deficit/transfers/spending) robust; output/price muddier (ZLB+COVID).\n")
