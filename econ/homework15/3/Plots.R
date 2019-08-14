# Plot Alone vs. Team:

mean_alone <- mean(profs$tenure_year[profs$strategy==0], na.rm=TRUE) # Some don't get tenure (NA)
sd_alone <- sd(profs$tenure_year[profs$strategy==0], na.rm=TRUE)

mean_team <- mean(profs$tenure_year[profs$strategy==1], na.rm=TRUE)
sd_team <- sd(profs$tenure_year[profs$strategy==1], na.rm=TRUE)

means <- c(mean_alone, mean_team)
sds <- c(sd_alone,sd_team)

p <- barplot(means, ylim=c(0,15), col=c("red","lightblue"), main="Average years to tenure", 
             xlab="Strategy", ylab="years")
axis(1, labels=c("Alone", "Team"), at = p)
segments(p, means - sds, p, means + sds, lwd=1)
segments(p - 0.1, means - sds, p + 0.1, means - sds, lwd=1)
segments(p - 0.1, means + sds, p + 0.1, means + sds, lwd=1)


# Plot Alone/Perf=0/Pref=1

mean_alone <- mean(profs$tenure_year[profs$strategy==0], na.rm=TRUE) # Some don't get tenure (NA)
sd_alone <- sd(profs$tenure_year[profs$strategy==0], na.rm=TRUE)

mean_no_pref <- mean(profs$tenure_year[profs$preference==0], na.rm=TRUE)
sd_no_pref <- sd(profs$tenure_year[profs$preference==0], na.rm=TRUE)

mean_pref <- mean(profs$tenure_year[profs$preference==1], na.rm=TRUE)
sd_pref <- sd(profs$tenure_year[profs$preference==1], na.rm=TRUE)

means <- c(mean_alone, mean_no_pref, mean_pref)
sds <- c(sd_alone,sd_no_pref,sd_pref)

p <- barplot(means, ylim=c(0,15), col=c("red","lightblue","blue"), main="Average years to tenure", 
             xlab="Strategy", ylab="years")
axis(1, labels=c("Alone", "No preference", "Preference for 1st"), at = p)
segments(p, means - sds, p, means + sds, lwd=1)
segments(p - 0.1, means - sds, p + 0.1, means - sds, lwd=1)
segments(p - 0.1, means + sds, p + 0.1, means + sds, lwd=1)

# Plot for time series: Alone vs. Team:
years <- 1:num_years
p <- plot(years,alone_avg_payoff,ylim=c(0,20),
     pch=19, type="l", col="red", xlab="Year", ylab="Average payoff", lwd=2)
lines(coop_avg_payoff, col="lightblue", pch=19, lwd=2, at=p)
legend_text <- c("Alone","Team")
legend(1,19, legend_text, lty=c(1,1), lwd=c(2.5,2.5), col= c( "red", "lightblue")) 

# Plot for time series: Alone/No Pref/Pref:
years <- 1:num_years
p <- plot(years,alone_avg_payoff,ylim=c(0,20),pch=19, type="l", col="red", xlab="Year", ylab="Average payoff", lwd=2)
lines(no_pref_avg_payoff, col="lightblue", pch=19, lwd=2, at=p)
lines(pref_avg_payoff, col="blue", pch=19, lwd=2, at=p)
legend_text <- c("Alone","No pref", "1st author pref")
legend(1,19, legend_text, lty=c(1,1), lwd=c(2.5,2.5), col= c( "red", "lightblue", "blue")) 




