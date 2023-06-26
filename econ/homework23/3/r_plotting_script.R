# loading the packages
library(dplyr)
library(readr)
library(stringr)
library(ggplot2)

# plotting the results of each of our simulation runs

# loading the files and specifying the number of turtles

filenames <- c("Results/experiment_5_turtles-table.csv",
               "Results/experiment_15_turtles-table.csv",
               "Results/experiment_25_turtles-table.csv")

n_turtles_list <- c(5, 15, 25)


for (i in 1:length(filenames)) {
  
  # load the results and tidy the NetLogo output up
  
  results <- read_csv(filenames[i], skip = 6)
  
  
  results <- filter(results, `[step]` != 0)
  
  colnames(results)[c(1, 7, 8, 13, 14, 15)] <- c("run_id", "random_seed", "step", "water_allocated_total", "generosity_leader", "who_leader")
  
  results$generosity_leader <- str_remove(results$generosity_leader,"\\[")
  results$generosity_leader <- str_remove(results$generosity_leader,"\\]")
  
  results$who_leader <- str_remove(results$who_leader,"\\[")
  results$who_leader <- str_remove(results$who_leader,"\\]")
  
  
  results$leader_count_list <- str_remove(results$leader_count_list,"\\[")
  results$leader_count_list <- str_remove(results$leader_count_list,"\\]")
  
  results$demerit_list <- str_remove(results$demerit_list,"\\[")
  results$demerit_list <- str_remove(results$demerit_list,"\\]")
  
  
  # Get columns from our lists, and prepare them into a wide format:
  # specify the number of turtles
  n_turtles <- n_turtles_list[i]
  
  leader_list_cols <- as.data.frame(str_split_fixed(results$leader_count_list, " ", n_turtles))
  demerit_list_cols <- as.data.frame(str_split_fixed(results$demerit_list, " ", n_turtles))
  
  colnames(leader_list_cols) <- paste0("leader_", c(1:n_turtles))
  colnames(demerit_list_cols) <- paste0("demerit_", c(1:n_turtles))
  
  ## recode the random seeds to run ids
  results$random_seed <- ifelse(results$random_seed == -353060595,
                                "1",
                                ifelse(results$random_seed == 154931709,
                                       "2", 
                                       ifelse(results$random_seed == 533568142,
                                              "3",
                                              ifelse(results$random_seed == 1752363490,
                                                     "4",
                                                     "5"))))
  
  # Tidy up the file, append leader and demerit parameters to the results file,
  # drop the old list columns:
  
  # dropping the list columns
  results_tidy <- results[, c(1:9, 12:15)]
  
  
  results_tidy <- cbind(results_tidy,
                        leader_list_cols,
                        demerit_list_cols)
  
  # convert factors to numeric
  
  results_tidy <- results_tidy %>% mutate_if(is.factor,as.character)
  results_tidy <- results_tidy %>% mutate_if(is.character,as.numeric)
  
  results_tidy$random_seed <- as.factor(results_tidy$random_seed)
  
  # add some labels to the variables of interest
  results_tidy$var <- paste0("v = ", results_tidy$var)
  
  results_tidy$demand_factor <- paste0("f = ", results_tidy$demand_factor)
  
  # plot the output
  plot <- results_tidy %>%
    group_by(demand_factor, var, step)%>%
    summarise(ave_genesority = mean(generosity_leader))%>%
    ggplot(., aes(x=step, y= ave_genesority),  size = 1.2, color = "red") +
    geom_line()+
    facet_grid(demand_factor ~ var)+
    labs(
      title = paste0("N = ", n_turtles_list[i]),
      y = "Leader Generosity",
      x = "Time",
      color = "Run")+
    ylim(0, 1)
  
  assign(paste0("plot_n_", n_turtles_list[i]), plot)
  
  #print the plots
  
  plot_filename <- paste0(paste0("Plots/", paste0("plot_n_", n_turtles_list[i])), ".png")
  
  png(filename = plot_filename,
      width = 10, height = 6, units = "in", res = 600)
  
  print(plot)
  
  dev.off()
  
  
  # plot the ids of leaders across runs for two values of variability
  plot_var <- results_tidy %>%
    filter(demand_factor == "f = 1.3" & var %in%  c("v = 0", "v = 0.5"))%>%
    ggplot(., aes(x=step, y= who_leader),  size = 1.2, color = "red") +
    geom_line() +
    facet_grid(var~random_seed)+
    labs(
      title = paste0("N = ", n_turtles_list[i]),
      y = "ID of leader",
      x = "Time",
      color = "Run")
  
  
  plot_filename <- paste0(paste0("Plots/", paste0("var_plot_n_", n_turtles_list[i])), ".png")
  
  png(filename = plot_filename,
      width = 10, height = 4, units = "in", res = 600)
  
  print(plot_var)
  
  dev.off()
  
  
  
}

