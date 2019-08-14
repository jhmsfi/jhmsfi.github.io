# empty workspace
rm(list = ls(all = TRUE))

set.seed(555)
# Creating a population of 20 agents. 10 work alone, 10 cooperate. 
# Out of 10 cooperators: 5 prefer to be first authors, 5 don't have a preference. 
ID <- 1:30
strategy <- c(rep(0,10),rep(1,20)) # 0 - alone, 1 - cooperate
preference <- c(rep(NA,10), rep(0,10), rep(1,10)) # NA - for alone. 0 - no preference, 1 - 1st authorship
payoff <- rep(0,length(ID))
updated_this_year <- rep(0,length(ID)) # 0 - unapdated, 1 - updated
tenure <- rep(0,length(ID))  # 0 - not tenure, 1 - tenure
tenure_year <- rep(NA,length(ID)) # year that the tenure threshold was crossed

# Create a population data frame:
profs <- data.frame( ID , strategy , preference , payoff , updated_this_year, tenure, tenure_year )

tenure_threshold <- 10 # need to create a tenure threshold
num_years <- 20

alone_pub_prob <- 0.7
team_pub_prob <- 0.4

alone_high_prob <- 0.5
team_high_prob <- 0.9
alpha <- 0.05 # penalty for being a second author

# Vectors to store infor for plots:
alone_avg_payoff <- rep(NA,num_years)
no_pref_avg_payoff <- rep(NA,num_years)
pref_avg_payoff <- rep(NA,num_years)
coop_avg_payoff <- rep(NA, num_years)

sd_alone_avg_payoff <- rep(NA,num_years)
sd_no_pref_avg_payoff <- rep(NA,num_years)
sd_pref_avg_payoff <- rep(NA,num_years)
sd_coop_avg_payoff <- rep(NA, num_years)



for (year in 1:num_years) {
    
    profs$updated_this_year <- 0
    
    # Pair cooperators:
    cooperators <- which(profs$strategy==1)
    cards <- sample(rep(1:(length(cooperators)/2),2))
    ego_prefs <- profs$preference[cooperators]
    partner_pref <- rep(NA,10)
    pref_match <- rep(NA,10)
        
    coop_matrix <- matrix (c(cooperators,cards,ego_prefs, partner_pref, pref_match) ,
                           nrow=length(cooperators) ,
                           ncol=5 ,
                           byrow=FALSE)
    
    # Compare preferences of paired colaborators:
    
    # Getting partner preferences:
    for (i in 1:length(cooperators)){
        
        
        pair <- which( coop_matrix[i,2] == coop_matrix[,2])
        partner_index <- which(pair!=i)
        partner <- pair[partner_index]
        partner_id <- coop_matrix[partner,1]
        partner_pref <- profs$preference[partner_id]
        coop_matrix[i,4] <- partner_pref
        
 
    # comparing the preferences:
        if (coop_matrix[i,3] + coop_matrix[i,4] == 0) {
            
            ego_authorship <- NA
            partner_authorship <- NA
            
            if (is.na(coop_matrix[i,5])){
            
         ego_authorship <- ifelse (runif(1) > 0.5, 1,0) # Assigns 1 as first author and 0 as a second author  
         coop_matrix[i,5] <- ego_authorship
         coop_matrix[partner,5] <- ifelse(ego_authorship==0,1,0)
         
                
            }
        }
    
    if(coop_matrix[i,3] + coop_matrix[i,4] == 1 ) {
        
        coop_matrix[i,5] <- coop_matrix[i,3] # ego's authorship
        coop_matrix[partner,5] <- coop_matrix[partner,3]
        
        
        }
    if(coop_matrix[i,3] + coop_matrix[i,4] == 2 ) {
        
        profs$updated_this_year[coop_matrix[i,1]] <- 1
        profs$updated_this_year[coop_matrix[partner,1]] <- 1
            
        }
    
    }
    
    # The fith column of the matrix indicates authorship for ths time step
    
    # Publishing this year? High impact journal? Payoffs:
    
    for (p in 1:length(profs$ID) ){
        
        # if professor works alone:
        if (profs$strategy[p] == 0 ){
            
            alone_payoff <- ifelse ( runif(1) > alone_pub_prob, 0, 
                                        ifelse( runif(1) < alone_high_prob , 2, 1) ) 
            
            
            profs$payoff[p] <- profs$payoff[p] + alone_payoff
        }
        
        if (profs$strategy[p] == 1 ){
            
            if (profs$updated_this_year[p] == 0){ 
            
           publish <- ifelse (runif(1) > team_pub_prob, 0, 1)
           
           
           if (publish==1){ 
               
        journal_impact <- ifelse( runif(1) < team_high_prob, 1,0) # 1 - high impact, 0 - low impact
           
           established_authorship <- coop_matrix[which(coop_matrix[,1]==p),5]
                                                                            
            ego_payoff <- ifelse(journal_impact==0 & established_authorship==0, 1 - alpha , 
                                      ifelse(journal_impact==0 & established_authorship==1, 1 + alpha ,
                                             ifelse(journal_impact==1 & established_authorship==0, 2 - alpha , 2 + alpha)))
           
           partner_payoff <- ifelse(ego_payoff==1 + alpha, 1 - alpha, 
                                    ifelse(ego_payoff==2 + alpha, 2 - alpha,
                                           ifelse(ego_payoff == 1 - alpha, 1 + alpha, 2 + alpha )))
           
           pair <- which( coop_matrix[,2] == coop_matrix[which(coop_matrix[,1]==profs$ID[p]),2])
           partner_index <- which(coop_matrix[pair,1]!=p)
           partner <- pair[partner_index]
           partner_id <- coop_matrix[partner,1]
           
           profs$payoff[p] <- ifelse(publish==0, profs$payoff[p] + 0, profs$payoff[p] + ego_payoff)
           profs$payoff[partner_id] <- ifelse(publish==0,profs$payoff[p] + 0, profs$payoff[partner] + partner_payoff)
           profs$updated_this_year[p] <- 1
           profs$updated_this_year[partner_id] <- 1
           }
                                                 
            }
        }
        
    }
    
    # Collect data on payoff for that year:
    alone_avg_payoff[year] <- mean(profs$payoff[profs$strategy==0], na.rm=TRUE)
    no_pref_avg_payoff[year] <- mean(profs$payoff[profs$preference==0], na.rm=TRUE)
    pref_avg_payoff[year] <- mean(profs$payoff[profs$preference==1], na.rm=TRUE)
    
    # all cooperators:
    coop_avg_payoff[year] <- mean(profs$payoff[profs$strategy==1], na.rm=TRUE)
    
    # standard deviations:
    
    sd_alone_avg_payoff[year] <- sd(profs$payoff[profs$strategy==0], na.rm=TRUE)
    sd_no_pref_avg_payoff[year] <- sd(profs$payoff[profs$preference==0], na.rm=TRUE)
    sd_pref_avg_payoff[year] <- sd(profs$payoff[profs$preference==1], na.rm=TRUE)
    sd_coop_avg_payoff[year] <- sd(profs$payoff[profs$strategy==1], na.rm=TRUE)
    
    
    
    # Tenure?
    for (t in 1:length(profs$ID)){
        
        if (profs$tenure[t]==0){ 
            if(profs$payoff[t] >= tenure_threshold ){ 
            
            profs$tenure[t] <- 1
            profs$tenure_year[t] <- year
            }
            
        }
    }
 
    
}
    
   
    
    
    


