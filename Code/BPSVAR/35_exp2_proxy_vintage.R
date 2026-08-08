# =====================================================================
# 35_exp2_proxy_vintage.R   —  TRACK B, EXPERIMENT 2
# Does the monetary proxy VINTAGE matter? Compare pc1 (raw FF4-type policy
# surprise, closest to the paper's baseline instrument) vs MP_median
# (information-robust), each under sum vs timing aggregation. 2x2.
# External-IV monetary IRF on the Minnesota posterior-mean BVAR.
# Output: Outputs/Tables/exp2_proxy_vintage_results.csv
# =====================================================================
rm(list=ls())
setwd("/Users/andys/Desktop/University of Liechstenstein/The_Fiscal_Channels_of_Monetary _Policy/Fiscal_Channel_Replication/Fiscal_Channel_Replication")
vars<-c("real_GDP","GDP_deflator","EBP","y1_yield","fiscal_deficit_ratio","real_tax_revenues","real_transfers","real_gov_spending")
p<-4;lambda<-0.2;H<-20
d<-read.csv("Data_Processing/Final_VAR_Dataset/baseline_var_dataset_v2.csv");d$date<-as.Date(d$date)
Y<-as.matrix(d[,vars]);Tn<-nrow(Y);n<-length(vars)
X<-cbind(1,do.call(cbind,lapply(1:p,function(i) Y[(p-i+1):(Tn-i),])));Yd<-Y[(p+1):Tn,];k<-ncol(X);rdates<-d$date[(p+1):Tn]
s<-sapply(1:n,function(i){yi<-Y[,i];sd(resid(lm(yi[-1]~yi[-length(yi)])))})
Yd_A<-rbind(diag(s)/lambda,matrix(0,n*(p-1),n));Xd_A<-cbind(matrix(0,n*p,1),kronecker(diag(1:p),diag(s))/lambda)
Xd_C<-matrix(0,1,k);Xd_C[1,1]<-1e-4
B<-solve(crossprod(rbind(Xd_A,matrix(0,n,k),Xd_C,X)),crossprod(rbind(Xd_A,matrix(0,n,k),Xd_C,X),rbind(Yd_A,diag(s),matrix(0,1,n),Yd)))
u<-Yd-X%*%B
companion<-function(B){A<-lapply(1:p,function(i) t(B[(2+(i-1)*n):(1+i*n),]));Phi<-list(diag(n))
  for(h in 1:H){S<-matrix(0,n,n);for(i in 1:p) if(h-i>=0) S<-S+A[[i]]%*%Phi[[h-i+1]];Phi[[h+1]]<-S};Phi}
Phi<-companion(B)
t<-read.csv("Raw_Data/Monetary_Shocks/shocks_fed_jk_t.csv");dt<-as.POSIXct(t$start,tz="UTC");day<-as.Date(dt)
qs<-as.Date(cut(day,"quarter"));qe<-as.Date(cut(qs+100,"quarter"))-1;fa<-as.numeric(qe-day)/as.numeric(qe-qs)
build<-function(col,rule){v<-suppressWarnings(as.numeric(t[[col]]));v[is.na(v)]<-0
  w<-if(rule=="sum") v else v*fa;cur<-tapply(w,as.character(qs),sum);q<-cur[match(as.character(rdates),names(cur))];q[is.na(q)]<-0;as.numeric(q)}
res<-data.frame()
for(col in c("pc1","MP_median")) for(rule in c("sum","timing")){
  m<-build(col,rule);mc<-m-mean(m);cov<-colMeans(mc*sweep(u,2,colMeans(u)));simp<-0.25*cov/cov[4]
  irf<-t(sapply(0:H,function(h) Phi[[h+1]]%*%simp));fs<-summary(lm(u[,4]~mc))$fstatistic[1]
  res<-rbind(res,data.frame(proxy=col,aggregation=rule,GDP_impact=irf[1,1],GDP_8q=irf[9,1],
    deflator_8q=irf[9,2],EBP_8q=irf[9,3],deficit_8q=irf[9,5],tax_8q=irf[9,6],first_stage_F=fs))
}
dir.create("Outputs/Tables",showWarnings=FALSE);write.csv(round_df<-cbind(res[1:2],round(res[-(1:2)],3)),
  "Outputs/Tables/exp2_proxy_vintage_results.csv",row.names=FALSE);print(round_df)
cat("\nFinding: BOTH info-robustness (MP_median>pc1) AND timing aggregation are needed;\n",
    "MP_median+timing gives the clean fiscal channel. pc1 (raw FF4) keeps a residual info-effect puzzle.\n")
