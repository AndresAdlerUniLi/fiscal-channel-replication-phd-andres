# =====================================================================
# 40_publication_figures.R   —  publication-grade exhibits
# Regenerates the paper-style figures & tables from the saved posterior
# draws (Stage 2 IRFs, Stage 3 counterfactuals). Base R only.
# Run 31_ and 34_ first (they save the .rds inputs).
# Output: Outputs/Figures/fig1_monetary_irf.pdf/.png
#         Outputs/Figures/fig2_counterfactuals.pdf/.png
#         Outputs/Tables/tab1_monetary_responses.{csv,tex}
#         Outputs/Tables/tab2_counterfactual_summary.csv
# =====================================================================
rm(list=ls())
setwd("/Users/andys/Desktop/University of Liechstenstein/The_Fiscal_Channels_of_Monetary _Policy/Fiscal_Channel_Replication/Fiscal_Channel_Replication")
dir.create("Outputs/Figures",showWarnings=FALSE,recursive=TRUE)
s2<-readRDS("Outputs/VAR/stage2_irf.rds"); IRF<-s2$IRF; vars<-s2$vars; H<-s2$H
TIT<-c("Output","Prices (GDP deflator)","Excess bond premium","One-year rate",
       "Fiscal deficit","Tax revenues","Transfers","Government spending")
UNIT<-c("%","%","pp","pp","pp of GDP","%","%","%"); jm<-1; hh<-0:H
qtile<-function(a,pr) apply(a,c(2,3,4),quantile,pr,na.rm=TRUE)
med<-qtile(IRF,.5);l68<-qtile(IRF,.16);u68<-qtile(IRF,.84);l90<-qtile(IRF,.05);u90<-qtile(IRF,.95)
band<-function(a,lo,hi,i,col,al) polygon(c(hh,rev(hh)),c(lo[,i,jm],rev(hi[,i,jm])),col=adjustcolor(col,al),border=NA)
draw_fig1<-function(){
  par(mfrow=c(2,4),mar=c(3.4,3.6,2.2,0.8),mgp=c(2,0.6,0),family="serif",cex.axis=.9)
  for(i in 1:8){
    yl<-range(l90[,i,jm],u90[,i,jm]);plot(hh,med[,i,jm],type="n",ylim=yl,xlab="",ylab=UNIT[i],main=TIT[i])
    band(IRF,l90,u90,i,"#4a6fa5",.18);band(IRF,l68,u68,i,"#4a6fa5",.35)
    abline(h=0,col="#444",lty=2);lines(hh,med[,i,jm],col="#1b3a6b",lwd=2)
    if(i>4) title(xlab="Quarters")}
  mtext("Figure 1.  Responses to a contractionary monetary policy shock (25 bp on the one-year rate)",
        outer=TRUE,line=-1.4,cex=.95,family="serif")}
pdf("Outputs/Figures/fig1_monetary_irf.pdf",width=11,height=5.4);draw_fig1();dev.off()
png("Outputs/Figures/fig1_monetary_irf.png",width=1500,height=760,res=140);draw_fig1();dev.off()
## ---- Figure 2: counterfactuals ----
s3<-readRDS("Outputs/VAR/stage3_counterfactuals.rds");OUT<-s3$OUT;PRC<-s3$PRC
scen<-c("baseline","no_tax","no_transfer","no_spending","no_fiscal")
lab<-c(baseline="Baseline",no_tax="No tax response",no_transfer="No transfer response",
       no_spending="No spending response",no_fiscal="No fiscal response")
col<-c(baseline="#111111",no_tax="#c0561b",no_transfer="#1f6cb0",no_spending="#2c8a4a",no_fiscal="#7a3294")
lty<-c(baseline=1,no_tax=2,no_transfer=2,no_spending=2,no_fiscal=1);lwd<-c(baseline=2.4,no_tax=1.4,no_transfer=1.4,no_spending=1.4,no_fiscal=2.4)
mm<-function(a)apply(a,2,median,na.rm=TRUE)
draw_fig2<-function(){
  par(mfrow=c(1,2),mar=c(3.6,3.8,2.4,0.8),mgp=c(2.2,0.6,0),family="serif")
  for(pan in list(list(OUT,"Output"),list(PRC,"Prices (GDP deflator)"))){
    L<-pan[[1]];rng<-range(sapply(scen,function(s)mm(L[[s]])))
    plot(hh,mm(L$baseline),type="n",ylim=rng,xlab="Quarters",ylab="%",main=pan[[2]])
    abline(h=0,col="#444",lty=2)
    for(s in scen) lines(hh,mm(L[[s]]),col=col[s],lty=lty[s],lwd=lwd[s])
    if(pan[[2]]=="Output") legend("bottomleft",legend=lab[scen],col=col[scen],lty=lty[scen],lwd=2,bty="n",cex=.8)}
  mtext("Figure 2.  Structural counterfactuals: the fiscal channel of monetary policy",outer=TRUE,line=-1.3,cex=.95,family="serif")}
pdf("Outputs/Figures/fig2_counterfactuals.pdf",width=9.5,height=4);draw_fig2();dev.off()
png("Outputs/Figures/fig2_counterfactuals.png",width=1300,height=560,res=140);draw_fig2();dev.off()
## ---- tables ----
hz<-c(1,5,9,13,21);hlab<-c("h=0","h=4","h=8","h=12","h=20")
t1<-data.frame(Variable=TIT);for(j in seq_along(hz)) t1[[hlab[j]]]<-sprintf("%+.3f",med[hz[j],,jm])
write.csv(t1,"Outputs/Tables/tab1_monetary_responses.csv",row.names=FALSE)
con<-file("Outputs/Tables/tab1_monetary_responses.tex","w")
writeLines(c(paste0("\\begin{tabular}{l",paste(rep("r",5),collapse=""),"}"),"\\hline",
  paste("Variable &",paste(hlab,collapse=" & "),"\\\\"),"\\hline",
  apply(t1,1,function(r)paste(paste(r,collapse=" & "),"\\\\")),"\\hline","\\end{tabular}"),con);close(con)
t2<-data.frame(scenario=lab[scen],output_q20=sapply(scen,function(s)round(mm(OUT[[s]])[21],3)),
               price_q20=sapply(scen,function(s)round(mm(PRC[[s]])[21],3)))
write.csv(t2,"Outputs/Tables/tab2_counterfactual_summary.csv",row.names=FALSE)
cat("Saved publication figures (pdf+png) and tables (csv+tex).\n")
