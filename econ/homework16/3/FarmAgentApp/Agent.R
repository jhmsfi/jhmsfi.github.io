agentFarm<-function(priceSwitch,pricePro,priceNotPro,effPro,effNotPro,benifitPro,benifitNotPro,nfarmersPro,nfarmersNotPro,nconsumersNotPro,nconsumersPro,nTicks){
  
#global
totalPrice<-pricePro+priceNotPro

#create farmers and consumers
nfarmers<-nfarmersPro+nfarmersNotPro
farmers<-data.frame(matrix(NA,nfarmers,7,byrow=TRUE))
colnames(farmers)<-c("TypeOfFarm","utility","nCons","Pswitch","Eff","Random","Price")

nconsumers<-nconsumersPro+nconsumersNotPro
consumers<-data.frame(matrix(NA,nconsumers,6,byrow=TRUE))
colnames(consumers)<-c("TypeOfFarm","utility","Pswitch","Benifit","Random","Price")

#starting Farm Types
farmers$TypeOfFarm<-c(rep("Pro",nfarmersPro),rep("NotPro",nfarmersNotPro))

#starting consumers
for (i in 1:nfarmers){
  if (farmers$TypeOfFarm[i]=="Pro"){
    farmers$nCons[i]<-nconsumersPro
  }else{
    farmers$nCons[i]<-nconsumersNotPro
  }
}

#set price
for (i in 1:nfarmers){
  if (farmers$TypeOfFarm[i]=="Pro"){
    farmers$Price[i]<-pricePro
  }else{
    farmers$Price[i]<-priceNotPro
  }
}

#set Effici
for (i in 1:nfarmers){
  if (farmers$TypeOfFarm[i]=="Pro"){
    farmers$Eff[i]<-effPro
  }else{
    farmers$Eff[i]<-effNotPro
  }
}

#consumer variables
consumers$TypeOfFarm<-c(rep("Pro",nconsumersPro),rep("NotPro",nconsumersNotPro))

#consumer Ben
for (i in 1:nconsumers){
  if (consumers$TypeOfFarm[i]=="Pro"){
    consumers$Benifit[i]<-benifitPro
  }else{
    consumers$Benifit[i]<-benifitNotPro
  }
}

#consumer Price
for (i in 1:nconsumers){
  if (consumers$TypeOfFarm[i]=="Pro"){
    consumers$Price[i]<-pricePro
  }else{
    consumers$Price[i]<-priceNotPro
  }
}

#set initial random
farmers$Random<-runif(nfarmers,0,1)
consumers$Random<-runif(nconsumers,0,1)

#calc initial utilities
farmers$utility<-((farmers$nCons*farmers$Price)-priceSwitch)/(nconsumers*farmers$Price)
farmers$Pswitch<-(1-(farmers$utility*farmers$Eff))*(1-farmers$nCons/nconsumers)


consumers$utility<-consumers$Benifit*(1-(consumers$Price/(totalPrice)))
consumers$Pswitch<-1-consumers$utility


#do trials
outcomeFarmersPro<-seq(0,(nTicks-1))
outcomeFarmersNotPro<-seq(0,(nTicks-1))

outcomeFarmersPro[1]<-nfarmersPro
outcomeFarmersNotPro[1]<-nfarmersNotPro

outcomeConsumersPro<-seq(0,(nTicks-1))
outcomeConsumersNotPro<-seq(0,(nTicks-1))
outcomeConsumersPro[1]<-nconsumersPro
outcomeConsumersNotPro[1]<-nconsumersNotPro


for ( i in 2:nTicks){
  for (k in 1:nfarmers){
  if(farmers$Pswitch[k]>farmers$Random[k]){
    farmers$TypeOfFarm[k]<-ifelse(farmers$TypeOfFarm[k]=="Pro","NotPro","Pro")
  }
  }
  outcomeFarmersPro[i]<-sum(farmers$TypeOfFarm=="Pro")
  outcomeFarmersNotPro[i]<-sum(farmers$TypeOfFarm=="NotPro")
  
  nfarmersPro<-outcomeFarmersPro[i]
  nfarmersNotPro<-outcomeFarmersNotPro[i]
  
  for (l in 1:nconsumers){
    if(consumers$Pswitch[l]>consumers$Random[l]){
      consumers$TypeOfFarm[l]<-ifelse(consumers$TypeOfFarm[l]=="Pro","NotPro","Pro")
    }
  }
  outcomeConsumersPro[i]<-sum(consumers$TypeOfFarm=="Pro")
  outcomeConsumersNotPro[i]<-sum(consumers$TypeOfFarm=="NotPro")
 
  nconsumersPro<-outcomeConsumersPro[i]
  nconsumersNotPro<-outcomeConsumersNotPro[i]
  
  for (j in 1:nfarmers){
    if (farmers$TypeOfFarm[j]=="Pro"){
      farmers$nCons[j]<-nconsumersPro
    }else{
      farmers$nCons[j]<-nconsumersNotPro
    }
  }
  
  for (m in 1:nconsumers){
    if (consumers$TypeOfFarm[m]=="Pro"){
      consumers$Benifit[m]<-benifitPro
    }else{
      consumers$Benifit[m]<-benifitNotPro
    }
  }
  
  for (n in 1:nconsumers){
    if (consumers$TypeOfFarm[n]=="Pro"){
      consumers$Price[n]<-pricePro
    }else{
      consumers$Price[n]<-priceNotPro
    }
  }
  farmers$Random<-runif(nfarmers,0,1)
  consumers$Random<-runif(nconsumers,0,1)
  farmers$utility<-((farmers$nCons*farmers$Price)-priceSwitch)/(nconsumers*farmers$Price)
  farmers$Pswitch<-((farmers$utility*farmers$Eff))*(farmers$nCons/nconsumers)
  
  
  consumers$utility<-consumers$Benifit*(1-(consumers$Price/(totalPrice)))
  consumers$Pswitch<-1-consumers$utility
}
  list(outcomeFarmersPro,outcomeFarmersNotPro,outcomeConsumersPro,outcomeConsumersNotPro)
}


  
  





