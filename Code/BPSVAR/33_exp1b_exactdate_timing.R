# =====================================================================
# 33_exp1b_exactdate_timing.R   —  TRACK B, EXPERIMENT 1b
# Sharpen Experiment 1 using JK's ANNOUNCEMENT-LEVEL surprises
# (shocks_fed_jk_t.csv, timestamped to each FOMC date). Weight each
# surprise by the exact fraction of its quarter occurring AFTER the
# announcement, then compare monetary-shock responses.
# Also writes the canonical timing-weighted monetary proxy.
#
# Output: Outputs/Tables/exp1b_exactdate_timing_results.csv
#         Data_Processing/Cleaned_Data/monetary_proxy_timed_quarterly.csv
# Verified against a Python reference.
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
## announcement-level surprises, exact within-quarter timing
t<-read.csv("Raw_Data/Monetary_Shocks/shocks_fed_jk_t.csv")
dt<-as.POSIXct(t$start,tz="UTC"); day<-as.Date(dt)
qs<-as.Date(cut(day,"quarter")); qe<-as.Date(cut(qs+100,"quarter"))-1        # quarter end
frac_after<-as.numeric(qe-day)/as.numeric(qe-qs)                              # fraction of qtr AFTER announcement
sv<-suppressWarnings(as.numeric(t$MP_median)); sv[is.na(sv)]<-0
build<-function(rule){
  if(rule=="sum") w<-sv
  else w<-sv*frac_after
  cur<-tapply(w,as.character(qs),sum); q<-cur[match(as.character(rdates),names(cur))]; q[is.na(q)]<-0
  if(rule=="carry"){ nq<-as.Date(cut(qs+100,"quarter")); nxt<-tapply(sv*(1-frac_after),as.character(nq),sum)
    add<-nxt[match(as.character(rdates),names(nxt))]; add[is.na(add)]<-0; q<-q+add }
  as.numeric(q)
}
res<-data.frame()
for(rule in c("sum","timing","carry")){
  m<-build(rule);mc<-m-mean(m);cov<-colMeans(mc*sweep(u,2,colMeans(u)));simp<-0.25*cov/cov[4]
  irf<-t(sapply(0:H,function(h) Phi[[h+1]]%*%simp));fs<-summary(lm(u[,4]~mc))$fstatistic[1]
  res<-rbind(res,data.frame(rule=paste0(rule,"_exactdate"),GDP_impact=irf[1,1],GDP_4q=irf[5,1],GDP_8q=irf[9,1],
    deflator_4q=irf[5,2],EBP_4q=irf[5,3],yield_impact=irf[1,4],first_stage_F=fs))
}
dir.create("Outputs/Tables",showWarnings=FALSE,recursive=TRUE)
write.csv(round(res,3),"Outputs/Tables/exp1b_exactdate_timing_results.csv",row.names=FALSE); print(round(res,3))
## canonical timing-weighted monetary proxy (MP_median & pc1)
mk<-function(colname){ v<-suppressWarnings(as.numeric(t[[colname]]));v[is.na(v)]<-0
  cur<-tapply(v*frac_after,as.character(qs),sum)
  grid<-seq(as.Date("1983-01-01"),as.Date("2019-10-01"),by="quarter")
  q<-cur[match(as.character(grid),names(cur))];q[is.na(q)]<-0;q }
grid<-seq(as.Date("1983-01-01"),as.Date("2019-10-01"),by="quarter")
write.csv(data.frame(date=grid,mp_median_timed=mk("MP_median"),mp_pc1_timed=mk("pc1")),
          "Data_Processing/Cleaned_Data/monetary_proxy_timed_quarterly.csv",row.names=FALSE)
cat("Saved timing-weighted monetary proxy -> monetary_proxy_timed_quarterly.csv\n")
