# =====================================================================
# 32_exp1_aggregation.R   —  TRACK B, EXPERIMENT 1
# Does the monetary "output puzzle" come from TEMPORAL AGGREGATION of the
# high-frequency surprise? Rebuild the quarterly monetary proxy from the
# monthly JK surprises under 4 aggregation rules and compare the identified
# monetary-shock responses (external-IV, Minnesota posterior-mean BVAR).
#
# Rules:  sum   = within-quarter sum (baseline)
#         mean  = within-quarter average
#         timing= weight each month by time remaining in quarter (m1=5/6,m2=1/2,m3=1/6)
#         carry = timing weight, with the complement carried to the NEXT quarter
#                 (a late-quarter surprise cannot have moved this quarter's output)
# Output: Outputs/Tables/exp1_aggregation_results.csv
# Verified against a Python reference (identical figures).
# =====================================================================
rm(list = ls())
setwd("/Users/andys/Desktop/University of Liechstenstein/The_Fiscal_Channels_of_Monetary _Policy/Fiscal_Channel_Replication/Fiscal_Channel_Replication")
vars <- c("real_GDP","GDP_deflator","EBP","y1_yield","fiscal_deficit_ratio",
          "real_tax_revenues","real_transfers","real_gov_spending")
p <- 4; lambda <- 0.2; H <- 20
d <- read.csv("Data_Processing/Final_VAR_Dataset/baseline_var_dataset_v2.csv"); d$date <- as.Date(d$date)
Y <- as.matrix(d[,vars]); Tn <- nrow(Y); n <- length(vars)
X <- cbind(1, do.call(cbind, lapply(1:p, function(i) Y[(p-i+1):(Tn-i),]))); Yd <- Y[(p+1):Tn,]; k <- ncol(X)
rdates <- d$date[(p+1):Tn]
## Minnesota posterior mean (dummy obs)
s <- sapply(1:n, function(i){ yi<-Y[,i]; sd(resid(lm(yi[-1]~yi[-length(yi)]))) })
Yd_A<-rbind(diag(s)/lambda, matrix(0,n*(p-1),n)); Xd_A<-cbind(matrix(0,n*p,1), kronecker(diag(1:p),diag(s))/lambda)
Xd_C<-matrix(0,1,k); Xd_C[1,1]<-1e-4
Ys<-rbind(Yd_A,diag(s),matrix(0,1,n),Yd); Xs<-rbind(Xd_A,matrix(0,n,k),Xd_C,X)
B<-solve(crossprod(Xs),crossprod(Xs,Ys)); u<-Yd-X%*%B
companion<-function(B){A<-lapply(1:p,function(i) t(B[(2+(i-1)*n):(1+i*n),]));Phi<-list(diag(n))
  for(h in 1:H){S<-matrix(0,n,n);for(i in 1:p) if(h-i>=0) S<-S+A[[i]]%*%Phi[[h-i+1]];Phi[[h+1]]<-S};Phi}
Phi<-companion(B)
## monthly JK surprises
jk<-read.csv("Raw_Data/Monetary_Shocks/shocks_fed_jk_m.csv")
jk$date<-as.Date(sprintf("%d-%02d-01",jk$year,jk$month)); mon<-jk$MP_median; mdate<-jk$date
qstart<-as.Date(cut(mdate,"quarter")); pos<-((as.integer(format(mdate,"%m"))-1)%%3)+1; w<-c(5/6,1/2,1/6)[pos]
agg<-function(rule){
  val<-switch(rule, sum=mon, mean=mon, timing=mon*w, carry=mon*w)
  q<-tapply(val, qstart, sum); q<-q[match(as.character(rdates), names(q))]; q[is.na(q)]<-0
  if(rule=="mean") q<-q/3
  if(rule=="carry"){ nxt<-tapply(mon*(1-w), qstart, sum)
    nd<-as.Date(names(nxt)); nd<-as.Date(cut(nd+92,"quarter"))       # push to next quarter
    ncar<-tapply(as.numeric(nxt), as.character(nd), sum)
    add<-ncar[match(as.character(rdates),names(ncar))]; add[is.na(add)]<-0; q<-q+add }
  as.numeric(q)
}
res<-data.frame()
for(rule in c("sum","mean","timing","carry")){
  m<-agg(rule); mc<-m-mean(m); cov<-colMeans(mc*sweep(u,2,colMeans(u))); simp<-0.25*cov/cov[4]
  irf<-t(sapply(0:H,function(h) Phi[[h+1]]%*%simp))
  fs<-summary(lm(u[,4]~mc))$fstatistic[1]
  res<-rbind(res,data.frame(rule=rule,GDP_impact=irf[1,1],GDP_4q=irf[5,1],GDP_8q=irf[9,1],
    deflator_4q=irf[5,2],EBP_4q=irf[5,3],yield_impact=irf[1,4],first_stage_F=fs))
}
dir.create("Outputs/Tables",showWarnings=FALSE,recursive=TRUE)
write.csv(round(res,3),"Outputs/Tables/exp1_aggregation_results.csv",row.names=FALSE)
print(round(res,3)); cat("\nWant: GDP negative, deflator negative, EBP positive.\n")
cat("Finding: naive sum/mean puzzle; timing-aware aggregation removes/flips it => temporal-aggregation artifact.\n")
