## Modeling Drivers entering a parking lot at a local mall with the intention to shop.
## This model assumes :
##  1) A set of Stores arranged in a line
##  2) Each parking row is parallel to the line of stores
##  3) Each row has the same number of parking spaces as there are stores
##  4) The preference of each customer is assigned uniformly randomly

## The parameters considered in the model are:
##     The arrival rate of cars
##     The departure rate of cars
##     The strategy used by each car to choose the parking space depends on:
##         its proximity to the store of preference (closest or furthest)
##

## The function park.buckets returns the distances from each car that has parked to its store
## of preference. To summarize it use summarize in R.
park.buckets <- function(NUMROWS=10, NUMCOLS=10, NITER=100, tofile=FALSE,strategy=0){
  STRATEGY_BREADTH <- 1
  STRATEGY_DEPTH <- 0
  
  rows <- matrix(0,nrow=NUMROWS,ncol=NUMCOLS)
  size <- NUMROWS*NUMCOLS
  arrivals <- rpois(NITER,10)
  departures <- rpois(NITER,10)
  count <- 1
  distance <- rep(0,sum(arrivals))
  carnum <- 1
  
  for(step in 1:NITER){
    deviation <- 0
    ## Number of cars arriving at this step
    vals <- sample(NUMCOLS,arrivals[step],replace=T)
    for(j in vals){
      cur <- 1
      tmp <- j
      ## Strategy exploring the space in breadth
      if(strategy==STRATEGY_DEPTH){
        while(rows[cur,tmp]==1){
          cur <- cur+1
          ## If column is full then explore the neighboring column
        if(cur>NUMROWS) {
          tmp <- tmp+1;
          cur <- 1
          if(tmp>NUMCOLS)
            next
        }
        }
      }
      if(strategy==STRATEGY_BREADTH){
        ## Strategy exploring the space in depth first style
        left <- right <- tmp
        while(rows[cur,left]==1){
          left <- left-1
          if(left<1) {
            cur <- cur+1
            deviation <- 0
            left <- tmp
            next;
          }
        }
        while(rows[cur,right]==1){
          right <- right+1
          if(right>NUMCOLS){
            cur <- cur+1
            deviation <- 0
            right <- tmp
            next
          }
        }
        if((tmp-left)>(right-tmp)){
          deviation <- tmp-left
          j <- left
        }
        else {
          j <- right
          deviation <- right-tmp
        }
      }
      
      if(cur<NUMROWS){
        rows[cur,j] <- 1

        distance[carnum] <- sqrt(j^2+deviation^2)
        carnum <- carnum+1
      }
      
      ## Departures
      departs <- which(rows==1)
      ## Uncomment the following to sample the departures using a distribution
      ##departing <- sample(departs,departures[step],replace=T)
      ## Comment this if the preceding is uncommented
      departing <- sample(departs,length(departs)/10)
      ## The car has departed
      rows[departing] <- 0

      ## Write the plot to a file and use an image generator such as ImageMagick to
      ## convert into an animation. Make sure to specify the path where the files get written
      if(tofile){
        filename <- paste(sep="",
                          "../R/ANIMATIONS/Parking/Parking-", step, ".png")
        png(filename)
      }
      plot(1:NUMROWS,1:NUMCOLS,
           type="n",xlab="Parking Row",ylab="Store Number",
           main="Spatial Distribution of a Mall Parking")
      grid()
        
      toaddx <- toaddy <- c()
      
      for(mwalkx in 1:NUMROWS)
        for(mwalky in 1:NUMCOLS){
          if(rows[mwalkx,mwalky] == 1){
            toaddx <- append(toaddx,mwalkx)
            toaddy <- append(toaddy,mwalky)
          }
        }
      points(toaddx,toaddy,xlim=c(1,NUMROWS),ylim=c(1,NUMCOLS),lwd=10,pch=22)
      
      if(tofile)
        dev.off()
    }

  }
  return(distance)
}

park.linear <- function(NUMSPACES=100,NITER=10,ENTRANCE=50){
  spaces <- rep(0,NUMSPACES)
  arrivals <- rpois(NITER,5)
 
  for(ncars in arrivals){
    for(count in 1:ncars){
      right <- left <- ENTRANCE
      while(spaces[right]==1){
         right <- right+1
         if(right>=NUMSPACES)
           break
       }
      while(spaces[left]==1){
        left <- left-1
        if(left<1) break
      }
      if(left<=0 && right<=NUMSPACES)
        spaces[right] <- 1

      if((ENTRANCE-left)<(right-ENTRANCE))
        spaces[left] <- 1
      else spaces[right] <- 1
      
      print(spaces)
    }
  }
}
