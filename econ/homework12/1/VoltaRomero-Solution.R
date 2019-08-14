# Changers, Keepers
# Felipe Romero, WashU
# Beniamino Volta, UCSD


# Initializes the parameters of the simulation
init<-function()
{
  politicalEnforcement<<-0.9
  numAgents<<-100
  
  # random distribution of commitments
  commitments<<-sample(c('K','U','C'),numAgents, replace=TRUE)
  
  # equally low distributions of keepers and changers
  #commitments<<-sample(c(rep("C",10),rep("K",10),rep("U",80)),numAgents)
  
  # more realistic scenario
  #commitments<<-sample(c(rep("C",5),rep("K",35),rep("U",60)),numAgents)
  
  # random distribution of happiness
  happiness<<-round(runif(numAgents,0,1),3)
  actualAgent<<-0
  numSteps<<-100
  printCommitments()
  
  plotc<<-NULL
  plotk<<-NULL
  plotu<<-NULL
  plotr<<-NULL
  plotp<<-NULL
}

# testing over all values of political enforcement
diffEnforcements<-function()
{
  plotc2<<-NULL
  plotk2<<-NULL
  plotu2<<-NULL
  for (i in 1:100)
  {
    commitments<<-sample(c('K','U','C'),numAgents, replace=TRUE)
    j<-i/100
    politicalEnforcement<<-j
    plotp<<-c(plotp,j)
    run()
    plotc2<<-c(plotc2,percentageChangers())
    plotk2<<-c(plotk2,percentageKeepers())
    plotu2<<-c(plotu2,percentageUndecided())
  }
}

# runs the simulation
run<-function()
{
  for (i in 1:numSteps)
  {
    step()
  }
}

# one iteration around the lattice
step<-function()
{
  plotc<<-c(plotc,percentageChangers())
  plotk<<-c(plotk,percentageKeepers())
  plotu<<-c(plotu,percentageUndecided())
  plotr<<-c(plotr,reaction())
  for (i in 1:numAgents)
  {
    updateCommitment(i)
  }
}

# updates the political commitment of undecided agents
updateCommitment<-function(agent)
{
  if (commitments[agent]=="U")
  {
    if (plurality(agent)=="K")
    {
      updateK(agent)
    }
    else if (plurality(agent)=="C")
    {
      updateC(agent)
    }
    else
    {
      # does nothing in case the numbers of keepers and changers around the agent are the same 
    }
    
  }
}

# finds the majority of commitments of agent's neighbors based on plurality rule
plurality<-function(agent)
{
  k<- sum(commitments[neighbors(agent)]=="K")
  u<- sum(commitments[neighbors(agent)]=="U")
  c<- sum(commitments[neighbors(agent)]=="C")

  if (k>c)
  {
    return ("K")
  }
  if (c>k)
  {
    return ("C")
  }
  
  return ("N")
}

# calculates government reaction at current time step 
reaction<-function()
{
  return ((2^(politicalEnforcement*percentageChangers()))-1)
}


# calulates the probability of becoming a keeper
updateK<-function(agent)
{
  k<- sum(commitments[neighbors(agent)]=="K")
  prob<-happiness[agent]*(k/4)*reaction()
  if (runif(1,0,1)<prob)
  {
    commitments[agent]<<-"K"
  }
}

# calulates the probability of becoming a changer
updateC<-function(agent)
{
  c<- sum(commitments[neighbors(agent)]=="C")
  prob<-(1-happiness[agent])*(c/4)*(1-reaction())
  if (runif(1,0,1)<prob)
  {
    commitments[agent]<<-"C"
  }
}

# plots relative amounts of changers, keepers and undecided across time 
plotResults<-function()
{
  plot(51,xlab='steps',ylab='agents',pch=3,xlim=c(0,100),ylim=c(0,1))
  lines(smooth.spline(plotc),col="blue",lwd=2)
  lines(smooth.spline(plotk),col="red",lwd=2)
  lines(smooth.spline(plotu),col="green",lwd=2)
  legend(60,0.95, c("Changers","Keepers","Undecided"), lty=c(1,1), lwd=c(2,2,2),col=c("blue","red","green"))
}

# plot number of keepers at the end of the simulation vs political enforcement value
plotEnforcement<-function()
{
  plot(c(1:100),plotc2,xlab='political enforcement',ylab='number of keepers',pch=3,xlim=c(0,100),ylim=c(0,1))
}


# MISC LATTICE FUNCTIONS

# gets the next agent in the lattice
getNext<-function()
{
  actualAgent<<-actualAgent+1
  if (actualAgent==(numAgents+1))
  {
    actualAgent<<-1
  }
  return (actualAgent)
}

# gets neighbors of the agent in the lattice
neighbors<-function(agent)
{
  if (agent == 1)
  {
    return (c(numAgents-1,numAgents,2,3))
  }
  if (agent == 2)
  {
    return (c(numAgents,1,3,4))
  }
  if (agent == (numAgents-1))
  {
    return (c(numAgents-3, numAgents-2, numAgents,1))
  }
  if (agent == (numAgents))
  {
    return (c(numAgents-2, numAgents-1, 1,2))
  }
  return (c(agent-2,agent-1,agent+1,agent+2))
}

# shows an array with the commitments of the agents
printCommitments<-function()
{
  print(paste(commitments, collapse=''))
}

# gives the percentage of changers in the lattice
percentageChangers<-function()
{
  return (sum(commitments=="C")/numAgents)
}

# gives the percentage of keepers in the lattice
percentageKeepers<-function()
{
  return (sum(commitments=="K")/numAgents)
}

# gives the percentage of undecided in the lattice
percentageUndecided<-function()
{
  return (sum(commitments=="U")/numAgents)
}

