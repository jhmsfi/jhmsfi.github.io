rm(list =ls())

#Defining an n agent m field model
n <- 1000
m <- 10
l <-100
i<-2
k<-1

y<-matrix(0, nrow=l+1,ncol=m)
x<-matrix(0, nrow=l+1,ncol=m)
g<-matrix(0, nrow=l+1,ncol=m)
prob<-matrix(0, nrow=l+2,ncol=m)
pp<-matrix(0, nrow=l+1,ncol=m)
t <- array (0, c(l+1))
prob[2,]<-1/m
para_prob <- (1/n)*0.1
count <- array( 0, c(m))

for (i in 2:l){
x[i,]<- rmultinom(1, n, prob[i,]) # no of papers in each field in this period
y[i,]<- y[i-1,]+x[i,] # total no. of papers in each field till date
pp[i,]<- x[i,]*para_prob # probability of a paradigm shift in the field
for (k in 1:m){
g[i,k] <-  x[i,k]/y[i,k]
para_shift <- rbinom(1,1,pp[i,k]) 
if (para_shift== 1) {
y[i,k] =0
count[k] = count [k] +1
g[i,k] =1}
if (x[i,k] ==0){
g[i,k] = 0
}
}
prob[i+1,] <- g[i,]/sum(g[i,])
t[i] <- i
i <- i +1
k<-1
}
  
t[l+1] <-l+1 
 