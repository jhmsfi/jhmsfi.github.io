setwd("~/")

mod.jokes <- function(N,tau,Pc,Pm,maxiter){#N: population size; tau: Saturation Threshold; Pc: probability of crossover; Pm: probability of bit-mutation; maxiter: maximum number of generations before it stops
z.data <- array(NA,c(8,8,maxiter)) #This will store the joke proportions data
abs.funniness <- array(NA,c(8,8)) # This will store the actual fitness landscape
avg.funniness <- array(NA,c(maxiter,1)) #This will store the average population fitness on each generation
offensive <- matrix(runif(64),nrow=8) #The randomly generating offesiveness of each joke, pi
bin2dec <- function(x){#Simple function to translate binary to decimal
		return(sum(2^(which(rev(x)==1)-1)))
	}
	well.paired <- function(x,y){#Indicator function to retrieve good pairs
		if((x%%2==0 & y%%2==0) | (x%%2!=0 & y%%2!=0) ){
			return(1)
		}else{
			return(0)
		}
	}
		
	funnyness <- function(chromosome,chromosome2,bin=TRUE){#Fitness function. It works with bin and dec. If dec, chromosome should code the Play on Words.
		if(bin){
			PoW <- bin2dec(chromosome[1:3]) # Play on Words
			Sub <- bin2dec(chromosome[4:6]) #Subject
		}else{
			PoW <- chromosome
			Sub <- chromosome2
			}
		neutrality <- offensive[PoW+1,Sub+1]
		return((PoW+neutrality*well.paired(PoW,Sub))) #Fitness function
		}
		
	mutate.bit<- function(x){#Bit-mutation function
		if(runif(1)<Pm){
			ifelse(x==1,return(0),return(1))
		}
		else{
			return(x)
		}
	}
		
		
	mutate.chrom <- function(x){#String mutation
		return(sapply(x,mutate.bit))
		}
		
	trim.saturated <- function(x){#Function to trim population from over.told jokes. 
		in.dec <- factor(apply(x,1,bin2dec),levels=seq(0,63))
		burnt.index <- in.dec%in%levels(in.dec)[(summary(in.dec)>(N*tau))]
		if(length(burnt.index)>2){
			over.told <- x[burnt.index,]
			not.over.told <-x[-burnt.index,]
			temp <-rbind(unique(over.told),not.over.told)
		}else{
			temp <- x
			}
		return(temp)
		}

for(i in 0:7){#This calculates the actual fitness of the whole joke space
	for(j in 0:7){
		abs.funniness[i+1,j+1] <- funnyness(i,j,bin=FALSE)
	}
}




joke.pop <- array(NA,c(N,6))
for(i in 1:dim(joke.pop)[1]){#Generate the initial population of jokes/chromosomes: first three bits code the PoW, last three bits code Subject
	joke.pop[i,] <- sample(c(1,0),size=6,replace=TRUE)
}



for(n in 1:maxiter){	#Genetic Algorithm. 1. Trim overtold jokes; 2. Choose parents and reproduce; 3. Mutate; 4. Discard old population.
		
#Check for 'saturated' jokes, and replace saturated ones
ok.jokes <- trim.saturated(joke.pop)
if(dim(ok.jokes)[1]<dim(joke.pop)[1]){
	new.jokes<-array(NA,c(N-dim(ok.jokes)[1],6))
	for(i in 1: dim(new.jokes)[1]){
		replacement.jokes.index <- sample(1:N,size=N-dim(ok.jokes)[1],replace=TRUE)
		replacement.jokes <- joke.pop[c(replacement.jokes.index),]
		#replacement.jokes <-t(apply(replacement.jokes,1,mutate.chrom))
		#new.jokes[i,]<-sample(c(1,0),size=6,replace=TRUE)
	}
	joke.pop <- rbind(ok.jokes,replacement.jokes)
}
	
#Calculate fitness (i.e. funnyness)
	fitness <- apply(joke.pop,1,funnyness)
#Choose parents
	avg.fitness <- mean(fitness)
	parents <- joke.pop[sample(1:N,N,replace=TRUE,prob=fitness/avg.fitness),]
	
#Form new pop


##Crossover
	new.joke.pop <- array(NA,c(N,6))
	for(i in seq(2,dim(parents)[1],by=2)){
		if(runif(1)<Pc){
			cross.point <- sample(1:5,1)
			offspring1 <- c(parents[i-1,1:cross.point],parents[i,(cross.point+1):6])
			offspring2 <- c(parents[i,1:cross.point],parents[i-1,(cross.point+1):6])
		}
		else{
			offspring1<- parents[i-1,]
			offspring2<-parents[i,]
		}
	new.joke.pop[i-1,] <- offspring1
	new.joke.pop[i,] <- offspring2
	}
##Mutate
new.joke.pop <- t(apply(new.joke.pop,1,mutate.chrom))

##Clone (one of) most fit jokes
#new.joke.pop[N,] <- joke.pop[sample(which(fitness==max(fitness)),1),]
#joke.pop <- new.joke.pop

#Fill matrices with joke.proportion data
jokes.in.pop1 <- factor(apply(joke.pop[,1:3],1,bin2dec)+1,levels=seq(1,8))
jokes.in.pop2 <- factor(apply(joke.pop[,4:6],1,bin2dec)+1,levels=seq(1,8))
z<- table(jokes.in.pop1,jokes.in.pop2)/N
z.data[,,n]<-z

avg.funniness[n,1] <- mean(apply(joke.pop,1,funnyness))
} # Calculate average fitness of the generation
result <- list(z.data,offensive,abs.funniness,avg.funniness)
names(result) <- c("Prop.Data","OffenseMatrix","Abs.Funniness","AverageFunniness")
return(result) #Return a list of proportions in each generation; the random offensiveness matrix; the complete fitness over joke-space; and a vector of average fitnesses on each generation
}

### END OF FUNCTION. 


## BEGINNING OF GRAPHS.
res.sim011 <- mod.jokes(500,tau=0.1,Pc=0.7,Pm=0.01,maxiter=90)
res.sim012 <- mod.jokes(500,tau=0.1,Pc=0.7,Pm=0.01,maxiter=90)
res.sim013 <- mod.jokes(500,tau=0.1,Pc=0.7,Pm=0.01,maxiter=90)
res.sim014 <- mod.jokes(500,tau=0.1,Pc=0.7,Pm=0.01,maxiter=90)
res.sim015 <- mod.jokes(500,tau=0.1,Pc=0.7,Pm=0.01,maxiter=90)

res.sim021 <- mod.jokes(500,tau=0.2,Pc=0.7,Pm=0.01,maxiter=90)
res.sim022 <- mod.jokes(500,tau=0.2,Pc=0.7,Pm=0.01,maxiter=90)
res.sim023 <- mod.jokes(500,tau=0.2,Pc=0.7,Pm=0.01,maxiter=90)
res.sim024 <- mod.jokes(500,tau=0.2,Pc=0.7,Pm=0.01,maxiter=90)
res.sim025 <- mod.jokes(500,tau=0.2,Pc=0.7,Pm=0.01,maxiter=90)

res.sim031 <- mod.jokes(500,tau=0.3,Pc=0.7,Pm=0.01,maxiter=90)
res.sim032 <- mod.jokes(500,tau=0.3,Pc=0.7,Pm=0.01,maxiter=90)
res.sim033 <- mod.jokes(500,tau=0.3,Pc=0.7,Pm=0.01,maxiter=90)
res.sim034 <- mod.jokes(500,tau=0.3,Pc=0.7,Pm=0.01,maxiter=90)
res.sim035 <- mod.jokes(500,tau=0.3,Pc=0.7,Pm=0.01,maxiter=90)

res.sim041 <- mod.jokes(500,tau=0.4,Pc=0.7,Pm=0.01,maxiter=90)
res.sim042 <- mod.jokes(500,tau=0.4,Pc=0.7,Pm=0.01,maxiter=90)
res.sim043 <- mod.jokes(500,tau=0.4,Pc=0.7,Pm=0.01,maxiter=90)
res.sim044 <- mod.jokes(500,tau=0.4,Pc=0.7,Pm=0.01,maxiter=90)
res.sim045 <- mod.jokes(500,tau=0.4,Pc=0.7,Pm=0.01,maxiter=90)

res.sim051 <- mod.jokes(500,tau=0.5,Pc=0.7,Pm=0.01,maxiter=90)
res.sim052 <- mod.jokes(500,tau=0.5,Pc=0.7,Pm=0.01,maxiter=90)
res.sim053 <- mod.jokes(500,tau=0.5,Pc=0.7,Pm=0.01,maxiter=90)
res.sim054 <- mod.jokes(500,tau=0.5,Pc=0.7,Pm=0.01,maxiter=90)
res.sim055 <- mod.jokes(500,tau=0.5,Pc=0.7,Pm=0.01,maxiter=90)

res.sim061 <- mod.jokes(500,tau=0.6,Pc=0.7,Pm=0.01,maxiter=90)
res.sim062 <- mod.jokes(500,tau=0.6,Pc=0.7,Pm=0.01,maxiter=90)
res.sim063 <- mod.jokes(500,tau=0.6,Pc=0.7,Pm=0.01,maxiter=90)
res.sim064 <- mod.jokes(500,tau=0.6,Pc=0.7,Pm=0.01,maxiter=90)
res.sim065 <- mod.jokes(500,tau=0.6,Pc=0.7,Pm=0.01,maxiter=90)

res.sim071 <- mod.jokes(500,tau=0.7,Pc=0.7,Pm=0.01,maxiter=90)
res.sim072 <- mod.jokes(500,tau=0.7,Pc=0.7,Pm=0.01,maxiter=90)
res.sim073 <- mod.jokes(500,tau=0.7,Pc=0.7,Pm=0.01,maxiter=90)
res.sim074 <- mod.jokes(500,tau=0.7,Pc=0.7,Pm=0.01,maxiter=90)
res.sim075 <- mod.jokes(500,tau=0.7,Pc=0.7,Pm=0.01,maxiter=90)

res.sim081 <- mod.jokes(500,tau=0.8,Pc=0.7,Pm=0.01,maxiter=90)
res.sim082 <- mod.jokes(500,tau=0.8,Pc=0.7,Pm=0.01,maxiter=90)
res.sim083 <- mod.jokes(500,tau=0.8,Pc=0.7,Pm=0.01,maxiter=90)
res.sim084 <- mod.jokes(500,tau=0.8,Pc=0.7,Pm=0.01,maxiter=90)
res.sim085 <- mod.jokes(500,tau=0.8,Pc=0.7,Pm=0.01,maxiter=90)

res.sim091 <- mod.jokes(500,tau=0.9,Pc=0.7,Pm=0.01,maxiter=90)
res.sim092 <- mod.jokes(500,tau=0.9,Pc=0.7,Pm=0.01,maxiter=90)
res.sim093 <- mod.jokes(500,tau=0.9,Pc=0.7,Pm=0.01,maxiter=90)
res.sim094 <- mod.jokes(500,tau=0.9,Pc=0.7,Pm=0.01,maxiter=90)
res.sim095 <- mod.jokes(500,tau=0.9,Pc=0.7,Pm=0.01,maxiter=90)

save.image(file="Jokes.RData")


sum.Popularity <- function(x1,x2,x3,x4,x5){
	sims.Popularity <- array(NA,c(8,8,90,5))
	sims.Popularity[,,,1]<-x1
	sims.Popularity[,,,2]<-x2
	sims.Popularity[,,,3]<-x3
	sims.Popularity[,,,4]<-x4
	sims.Popularity[,,,5]<-x5
	result <- apply(sims.Popularity,1:3,FUN=quantile,probs=0.5)
	return(result)
}

sum.Funniness <- function(x){
	avg.funniness <- array(NA,c(90,5))
	for(i in 1:5){
		avg.funniness[,i]<-x[,i]
		}
	means <- rowMeans(avg.funniness)
	sd <- apply(avg.funniness,1,sd)
	result <- cbind(means,means+(1.64*sd),means-(1.64*sd))
	}



pop.summary01<-sum.Popularity(res.sim011$Prop.Data,res.sim012$Prop.Data,res.sim013$Prop.Data,res.sim014$Prop.Data,res.sim015$Prop.Data)

pop.summary02<-sum.Popularity(res.sim021$Prop.Data,res.sim022$Prop.Data,res.sim023$Prop.Data,res.sim024$Prop.Data,res.sim025$Prop.Data)

pop.summary03<-sum.Popularity(res.sim031$Prop.Data,res.sim032$Prop.Data,res.sim033$Prop.Data,res.sim034$Prop.Data,res.sim035$Prop.Data)

pop.summary04<-sum.Popularity(res.sim041$Prop.Data,res.sim042$Prop.Data,res.sim043$Prop.Data,res.sim044$Prop.Data,res.sim045$Prop.Data)

pop.summary05<-sum.Popularity(res.sim051$Prop.Data,res.sim052$Prop.Data,res.sim053$Prop.Data,res.sim054$Prop.Data,res.sim055$Prop.Data)


pop.summary06<-sum.Popularity(res.sim061$Prop.Data,res.sim062$Prop.Data,res.sim063$Prop.Data,res.sim064$Prop.Data,res.sim065$Prop.Data)

pop.summary07<-sum.Popularity(res.sim071$Prop.Data,res.sim072$Prop.Data,res.sim073$Prop.Data,res.sim074$Prop.Data,res.sim075$Prop.Data)

pop.summary08<-sum.Popularity(res.sim081$Prop.Data,res.sim082$Prop.Data,res.sim083$Prop.Data,res.sim084$Prop.Data,res.sim085$Prop.Data)

pop.summary09<-sum.Popularity(res.sim091$Prop.Data,res.sim092$Prop.Data,res.sim093$Prop.Data,res.sim094$Prop.Data,res.sim095$Prop.Data)


fun.summary01<-sum.Funniness(cbind(res.sim011$AverageFunniness,res.sim012$AverageFunniness,res.sim013$AverageFunniness,res.sim014$AverageFunniness,res.sim015$AverageFunniness))

fun.summary02<-sum.Funniness(cbind(res.sim021$AverageFunniness,res.sim022$AverageFunniness,res.sim023$AverageFunniness,res.sim024$AverageFunniness,res.sim025$AverageFunniness))

fun.summary03<-sum.Funniness(cbind(res.sim031$AverageFunniness,res.sim032$AverageFunniness,res.sim033$AverageFunniness,res.sim034$AverageFunniness,res.sim035$AverageFunniness))

fun.summary04<-sum.Funniness(cbind(res.sim041$AverageFunniness,res.sim042$AverageFunniness,res.sim043$AverageFunniness,res.sim044$AverageFunniness,res.sim045$AverageFunniness))

fun.summary05<-sum.Funniness(cbind(res.sim051$AverageFunniness,res.sim052$AverageFunniness,res.sim053$AverageFunniness,res.sim054$AverageFunniness,res.sim055$AverageFunniness))

fun.summary06<-sum.Funniness(cbind(res.sim061$AverageFunniness,res.sim062$AverageFunniness,res.sim063$AverageFunniness,res.sim064$AverageFunniness,res.sim065$AverageFunniness))

fun.summary07<-sum.Funniness(cbind(res.sim071$AverageFunniness,res.sim072$AverageFunniness,res.sim073$AverageFunniness,res.sim074$AverageFunniness,res.sim075$AverageFunniness))

fun.summary08<-sum.Funniness(cbind(res.sim081$AverageFunniness,res.sim082$AverageFunniness,res.sim083$AverageFunniness,res.sim084$AverageFunniness,res.sim085$AverageFunniness))

fun.summary09<-sum.Funniness(cbind(res.sim091$AverageFunniness,res.sim092$AverageFunniness,res.sim093$AverageFunniness,res.sim094$AverageFunniness,res.sim095$AverageFunniness))

setwd("~/Desktop/Jokes/")

draw.popularity <- function(x,name){
for(i in 1:dim(x)[3]){
	pdf(file=paste(name,i,".pdf",sep=""))
	image(x=seq(1,8),y=seq(1,8),z=1-x[,,i], main = i,xlab="Play on Words",ylab="Subject")
	dev.off()
}
}

pdf("funniness.pdf")
	par(mfrow=c(3,3))
	plot(fun.summary01[,2],type="l",lty=3,ylim=c(2,6),ylab="Funniness",xlab="Generation",main="Saturation 0.1")
	lines(fun.summary01[,1],lty=1)
	lines(fun.summary01[,3],lty=3)
	
	plot(fun.summary02[,2],type="l",lty=3,ylim=c(2,6),ylab="Funniness",xlab="Generation",main="Saturation 0.2")
	lines(fun.summary02[,1],lty=1)
	lines(fun.summary02[,3],lty=3)
	
	plot(fun.summary03[,2],type="l",lty=3,ylim=c(2,6),ylab="Funniness",xlab="Generation",main="Saturation 0.3")
	lines(fun.summary03[,1],lty=1)
	lines(fun.summary03[,3],lty=3)
	
	plot(fun.summary04[,2],type="l",lty=3,ylim=c(2,6),ylab="Funniness",xlab="Generation",main="Saturation 0.4")
	lines(fun.summary04[,1],lty=1)
	lines(fun.summary04[,3],lty=3)
	
	plot(fun.summary05[,2],type="l",lty=3,ylim=c(2,6),ylab="Funniness",xlab="Generation",main="Saturation 0.5")
	lines(fun.summary05[,1],lty=1)
	lines(fun.summary05[,3],lty=3)
	
	plot(fun.summary06[,2],type="l",lty=3,ylim=c(2,6),ylab="Funniness",xlab="Generation",main="Saturation 0.6")
	lines(fun.summary06[,1],lty=1)
	lines(fun.summary06[,3],lty=3)
	
	plot(fun.summary07[,2],type="l",lty=3,ylim=c(2,6),ylab="Funniness",xlab="Generation",main="Saturation 0.7")
	lines(fun.summary07[,1],lty=1)
	lines(fun.summary07[,3],lty=3)
	
	plot(fun.summary08[,2],type="l",lty=3,ylim=c(2,6),ylab="Funniness",xlab="Generation",main="Saturation 0.8")
	lines(fun.summary08[,1],lty=1)
	lines(fun.summary08[,3],lty=3)
	
	plot(fun.summary09[,2],type="l",lty=3,ylim=c(2,6),ylab="Funniness",xlab="Generation",main="Saturation 0.9")
	lines(fun.summary09[,1],lty=1)
	lines(fun.summary09[,3],lty=3)
dev.off()



draw.popularity(pop.summary01,"Popularity01")
draw.popularity(pop.summary02,"Popularity02")
draw.popularity(pop.summary03,"Popularity03")
draw.popularity(pop.summary04,"Popularity04")
draw.popularity(pop.summary05,"Popularity05")
draw.popularity(pop.summary06,"Popularity06")
draw.popularity(pop.summary07,"Popularity07")
draw.popularity(pop.summary08,"Popularity08")
draw.popularity(pop.summary09,"Popularity09")


