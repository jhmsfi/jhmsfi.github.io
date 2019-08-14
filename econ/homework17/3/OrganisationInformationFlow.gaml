/**
* Name: OrganisationInformationFlow
* Author: masc2593
* Description: homework for Graduate workshop social complex computational modelling. 
Information flows across trusted members of an organization
* Tags: Tag1, Tag2, TagN
*/

model OrganisationInformationFlow

global {
	/** Insert the global definitions, variables and actions here */
	float mean_info_loss_per_day <- 0.03;
	float max_recovery_from_debrief <- 0.02; // if your accuracy is at 0 from personal benefit
	float proportional_benefit_from_group_accuracy <- 0.2; 
	int nr_of_members <- 4;
	int days_between_debrief <- 7;
	float coffee_learning_constant <- max_recovery_from_debrief / (100*days_between_debrief);
	//float max_trust <- 1;
	
	// initialize agents
	init {
		create member_org number:nr_of_members;	
		}
		
	// execute actions in right order
	reflex order_of_activities { 
     	ask member_org {do info_dissipation;}
    	if (mod(time, days_between_debrief) = 0) {
    		ask member_org {do weekly_debrief;}
    	}
    	ask member_org {do coffee_break;}
    	
	}	

	
}

species member_org {
	// attributes of species are attributed below the species (not in the global where you create the species)
	//float level_of_trust <- rnd(0,max_trust);
	float accuracy_of_info <- min([gauss(0.25,0.20),1]); 
	float loss_of_info_per_day <- gauss(mean_info_loss_per_day,0.01);
	//float loss_of_info_per_day <- mean_info_loss_per_day;
	float mean_accuracy_over_all_members <- 0.0;
	float gain_in_accuracy_of_info <- 0.0;
	float gain_in_accuracy_from_coffee <- 0.0;
	float max_trust_level <- 5.0;
	float trust_level <- rnd(max_trust_level);
	
			
	action info_dissipation {
		// make sure info loss is not negative --> then learns
		if (loss_of_info_per_day<=0.0) {
			loss_of_info_per_day<- 0.01;
		}
		//bound the accurcay between 0 and 1
		if (accuracy_of_info>1) {
			accuracy_of_info <- 1.0;
		}
		else if (accuracy_of_info<0) {
			accuracy_of_info <- 0.0;
		} 
		// forget
		accuracy_of_info <- accuracy_of_info - accuracy_of_info*loss_of_info_per_day;
		//accuracy_of_info <- 2.7 * (time,-0.1);
		
		// bound accurcay again
		if (accuracy_of_info>1) {
			accuracy_of_info <- 1.0;
		}
		else if (accuracy_of_info<0) {
			accuracy_of_info <- 0.0;
		} 
	}
	
	action weekly_debrief {
		mean_accuracy_over_all_members <- mean_of(member_org,accuracy_of_info);
		gain_in_accuracy_of_info <- (mean_accuracy_over_all_members*proportional_benefit_from_group_accuracy +(max_recovery_from_debrief-accuracy_of_info*max_recovery_from_debrief));
		//gain_in_accuracy_of_info <- (accuracy_of_info-mean_accuracy_over_all_members)*
		accuracy_of_info <- accuracy_of_info + gain_in_accuracy_of_info;
		// bound accurcay again
		if (accuracy_of_info>1) {
			accuracy_of_info <- 1.0;
		}
		else if (accuracy_of_info<0) {
			accuracy_of_info <- 0.0;
		} 
	}	
	action coffee_break {
		// 1. pair up people randomly: select one random coffee break buddy
		member_org my_buddy_member <- one_of(member_org);
		
		// 2. calculate the gain from the coffee break based on the accurcay and trust of the budy
		gain_in_accuracy_from_coffee <- (max_trust_level + my_buddy_member.trust_level - self.trust_level)*(self.accuracy_of_info+my_buddy_member.accuracy_of_info)*coffee_learning_constant;
		accuracy_of_info <- accuracy_of_info +	gain_in_accuracy_from_coffee;
	    //3.  bound accurcay again
		if (accuracy_of_info>1) {
			accuracy_of_info <- 1.0;
		}
		else if (accuracy_of_info<0) {
			accuracy_of_info <- 0.0;
		} 
		}				

} 

	


experiment OrganisationInformationFlow type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display info_of_all_members{
			chart "time series of accuracy of infromation of all members individually" type: series {
				loop i over: member_org {
					data "information accuracy member "+int(i) value: i.accuracy_of_info;				
					}
			}
		}
	}
}
