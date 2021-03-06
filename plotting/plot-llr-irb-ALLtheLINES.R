#---------------------------------------------------------------------
# From llr-v-irb-plots.R
# simply repeats the code from llr-v-irb
# in order to plot up every single expected loss scenario
# perhaps one day this script can be modified to present shaded range
# instead of so many lines
#
# Patricia L 4/18/2014
#----------------------------------------------------------------------

# load saved model data
  rm(list=ls())
  folder = 'W:\\Research\\Energy Efficiency\\EE Finance toy model\\'
  scenario = 'old.IRB\\sensitivityRiskPremia'#what set of non-intervention params do you want?
  
  run.name='' #used to save this set of params for later use/reference, should you desire.
  
  load(file=paste(folder,"model-runs\\",scenario,run.name,".R",sep=''))
  # contains list=c('inlist','README','inputs','results','scenario')

  # need to re-create indexing variables
  LLR = results[,"LSR"]>0 & results[,"upfront.rebate"]==0 & results[,"interest.buydown"]==0
  IRB = results[,"LSR"]==0 & results[,"upfront.rebate"]==0 & results[,"interest.buydown"]>0
  rebate = results[,"LSR"]==0 & results[,"interest.buydown"]==0
  nothing = results[,"LSR"]==0 & results[,"upfront.rebate"]==0 & results[,"interest.buydown"]==0
  no.loss=results[,"chance.full.loss"]==0
  no.recovery = results[,"recovery"]==0


# tapply: finding the measn/sd of a given column for each unique combination of the factors in INDEX
gvt.means = tapply(results[,"gvt.cost.NPV"],INDEX=results[,c("LSR","LPCR","interest.buydown","risk.adjust")], FUN=mean)
userpmt.means = tapply(results[,"loan.payment.user"],INDEX=results[,c("LSR","LPCR","interest.buydown","risk.adjust")], FUN=mean)
#userpmt.sd = tapply(result[,"loan.payment.user"],INDEX=result[,c("LSR","LPCR","interest.buydown")], FUN=sd)

#!# TODO: Make alternate script that plots consumer interest rate instead of userpmt, in a nicer way than this:
interest.means = tapply(results[,"interest.user"],INDEX=results[,c("LSR","LPCR","interest.buydown","risk.adjust")], FUN=mean)
userpmt.means=interest.means

#!# For some reason the tapply results return NA for mean loan.payment.user when interest.buydown=interest.bank AND LSR !=0
#!#! fortunately we are not interested in these results, but it is still an issue that would be nice to resolve
# dim 1 is LSR
# dim 2 is LPCR
# dim 3 is interest.buydown
# dim 4 is risk.adjust
# userpmt.means[1,,,] is the sheet with 0 LSR (i.e. no LLR)
# userpmt.means[,,1,] is the sheet with no IRB
# userpmt.means[2:dim(userpmt.means)[1],,1,] is the sheet with an active LLR
# to extract the data from dimnames, which are the values of the
# INDEX variables used in tapply
# change the # in double brackets to access a different INDEX variable
#as.numeric(dimnames(userpmt.means)[[2]]))

#set graph limits
  xl = c(-5000,0)#range(gvt.means[],na.rm=T)
  yl = c(0,12)#range(userpmt.means[],na.rm=T)


## first plot low range ##

  loss.index=1
  plot(y= c(userpmt.means[1,1,1,loss.index],userpmt.means[2:dim(userpmt.means)[1],,1,loss.index]), # c() concatenates a singular zero point
  x= c(gvt.means[1,1,1,loss.index], gvt.means[2:dim(userpmt.means)[1],,1,loss.index]), #start with the LLR (IRB = 0 & LSR != 0)
  xlab= "NPV, cost to government ($)",
  ylab= "Consumer's interest rate (%)",
  pch=1,
  col=1,
  xlim=xl, ylim=yl,
  type='o')

# now plot points with an LLR and without an IRB

  points(y= c(userpmt.means[1,1,1,loss.index], userpmt.means[1,1,1:dim(userpmt.means)[3],loss.index]), #doesn't matter what sheet we use in 2nd dim since LPCR is irrelevant
  x= c(gvt.means[1,1,1,loss.index],gvt.means[1,1,1:dim(userpmt.means)[3],loss.index]),
  pch=4,
  col=2,
  type='o')

##  Now repeat for all the other loss indices ##

for (loss.index in c(3,5)){
  points(y= c(userpmt.means[1,1,1,loss.index],userpmt.means[2:dim(userpmt.means)[1],,1,loss.index]), # c() concatenates a singular zero point
  x= c(gvt.means[1,1,1,loss.index], gvt.means[2:dim(userpmt.means)[1],,1,loss.index]), #start with the LLR (IRB = 0 & LSR != 0)
  pch=1,
  col=1,
  type='o')
  # now plot points with an LLR and without an IRB
  points(y= c(userpmt.means[1,1,1,loss.index], userpmt.means[1,1,1:dim(userpmt.means)[3],loss.index]), #doesn't matter what sheet we use in 2nd dim since LPCR is irrelevant
  x= c(gvt.means[1,1,1,loss.index],gvt.means[1,1,1:dim(userpmt.means)[3],loss.index]),
  pch=4,
  col=2,
  type='o')
  dim(userpmt.means)[[4]]
}

## plot acoutrements ##
  #legend('topleft', legend = c("Loan Loss Reserve","Interest rate buydowns"), pch=c(1,4),col=c(1,2))
  legend('topleft',
         legend = c(paste("Loan Loss Reserve:\n",min(results[LLR,"LPCR"])*100,"% - ",max(results[LLR,"LPCR"])*100,"% LPCR",sep=''),
                    paste("Interest rate buydown:\n",min(results[,"interest.buydown"])*100,"% - ",
                          round(max(results[,"interest.buydown"])*100,digits=6),"%",sep='')),
         pch=c(1,4),
         col=c(1,2),
         bty='n')
  title(main="Comparing costs and effects of IRB and LLR",sub=paste("Tenor=",results[,"tenor"],", Project cost=",results[,"eecost"],". RunID:",scenario,sep=''))
  abline(h=0)


# optional #
# abline(lm(userpmt.means[1,1,1:dim(userpmt.means)[3],loss.index] ~ gvt.means[1,1,1:dim(userpmt.means)[3],loss.index]), col='blue')
