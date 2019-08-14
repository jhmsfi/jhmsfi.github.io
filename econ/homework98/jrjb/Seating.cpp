#include <iostream.h>
#include <stdlib.h>
#include <stdio.h>

#define NUM_OF_COL		12
#define NUM_OF_ROW		12
#define NUM_OF_GROUP	1
#define NUM_OF_PREF		1
#define NUM_OF_AGENT	100

struct Agent
{

	//0:gender 
	int group[NUM_OF_GROUP];
	//0:gender
	int pref[NUM_OF_PREF];

	//0:col 1:row
	int loc[2];
	//0:aisle 1:front 2:back 3:middle 
	int locPref[4];

	int solitude;

};

struct Seat
{
	int agentID;
	int aisle;
	int front;
	int back;
	int middle;

};

float GetRand();

void main(void)
{
	FILE *out, *out1,*out2,*out3,*out4,*out5,*out6,*out7,*out8;
	out=fopen("init1.dat","w");
	out1=fopen("init2.dat","w");
	out2=fopen("position.dat","w");
	out3=fopen("aisle.dat","w");
	out4=fopen("front.dat","w");
	out5=fopen("back.dat","w");
	out6=fopen("middle.dat","w");
	out7=fopen("group.dat","w");
	out8=fopen("solitude.dat","w");
	srand(1767322);
	Seat seats[NUM_OF_COL][NUM_OF_ROW];
	Agent agents[NUM_OF_AGENT];
	for(int i=0;i<NUM_OF_ROW;i++){
		for(int j=0;j<NUM_OF_COL;j++){
			seats[i][j].agentID=-1;

			if(i==0 || i==11 || j==0 || j==11){
				seats[i][j].middle=-1;
				seats[i][j].aisle=-1;
				seats[i][j].front=-1;
				seats[i][j].back=-1;
			}
			else{
				if(i>1 && i<10 && j>1 && j<10){
					seats[i][j].middle=1;
					seats[i][j].aisle=-1;
					seats[i][j].front=-1;
					seats[i][j].back=-1;
				}
				else{
					seats[i][j].middle=-1;
					if(j==1 || j==10)
						seats[i][j].aisle=1;
					else
						seats[i][j].aisle=-1;
					if(i==1)
						seats[i][j].front=1;
					else
						seats[i][j].front=-1;
					if(i==10)
						seats[i][j].back=1;
					else
						seats[i][j].back=-1;
				}
			}

			fprintf(out,"row: %d\tcol: %d\tID: %d\ta: %d\tf: %d\tb: %d\tw: %d\n",
				i,j,seats[i][j].agentID,seats[i][j].aisle,
				seats[i][j].front,seats[i][j].back,seats[i][j].middle);

		}

	}

	for(int thisAgent=0;thisAgent<NUM_OF_AGENT;thisAgent++){

		if(GetRand()>0.5){
			agents[thisAgent].group[0]=1; //male
			agents[thisAgent].pref[0]=1; 
		}
		else{
			agents[thisAgent].group[0]=-1;
			agents[thisAgent].pref[0]=-1; 
		}
		fprintf(out1,"%d\t%d\t",
				agents[thisAgent].group[0],agents[thisAgent].pref[0]);
	
		//0:col 1:row
		agents[thisAgent].loc[0]=-1;
		agents[thisAgent].loc[1]=-1;
		fprintf(out1,"%d\t%d\t",
				agents[thisAgent].loc[0],agents[thisAgent].loc[1]);

		//0:front 1:end 2:aisle 3:middle 
		for(int thisLoc=0;thisLoc<4;thisLoc++){
			if(GetRand()>0.5)
				agents[thisAgent].locPref[thisLoc]=-1; 
			else
				agents[thisAgent].locPref[thisLoc]=1; 

			fprintf(out1,"%d\t",
				agents[thisAgent].locPref[thisLoc]);
		}

		if(GetRand()>0.5)
			agents[thisAgent].solitude=-1; 
		else
			agents[thisAgent].solitude=1; 
		fprintf(out1,"%d\n",
				agents[thisAgent].solitude);


	}

	for(thisAgent=0;thisAgent<NUM_OF_AGENT-50;thisAgent++){
		
		float utility;
		float max=-100000;
		int rowid;
		int colid;
		int found=0;
		for(int i=1;i<NUM_OF_ROW-1;i++){
			for(int j=1;j<NUM_OF_COL-1;j++){
				if(seats[i][j].agentID==-1){
					int leftG=0;
					int rightG=0;
					if(seats[i-1][j].agentID!=-1){
						leftG=agents[seats[i-1][j].agentID].group[0];

					}
					if(seats[i+1][j].agentID!=-1){
						rightG=agents[seats[i+1][j].agentID].group[0];

					}
					int leftS=0;
					int rightS=0;
					if(seats[i-1][j].agentID!=-1){
						leftS=1;

					}
					if(seats[i+1][j].agentID!=-1){
						rightS=1;

					}
					utility=agents[thisAgent].locPref[0]*seats[i][j].aisle+
							agents[thisAgent].locPref[1]*seats[i][j].front+
							agents[thisAgent].locPref[2]*seats[i][j].back+
							agents[thisAgent].locPref[3]*seats[i][j].middle+
							agents[thisAgent].pref[0]*leftG+
							agents[thisAgent].pref[0]*rightG+
							agents[thisAgent].solitude*leftS+
							agents[thisAgent].solitude*rightS+
							GetRand();
							found=1;

				}
			
				if(utility>max  && found==1){
					max=utility;
					rowid=i;
					colid=j;
				}
			}
		}
		seats[rowid][colid].agentID=thisAgent;
	}

	for(i=0;i<NUM_OF_ROW;i++){
		for(int j=0;j<NUM_OF_COL;j++){
			if(i==0 ||i==(NUM_OF_ROW-1)||j==0||j==(NUM_OF_COL-1)
				|| seats[i][j].agentID ==-1){
				fprintf(out2,"<TD><CENTER>%d</CENTER></TD>",
					seats[i][j].agentID);

				fprintf(out3,"<TD><CENTER>%d</CENTER></TD>",0);
				fprintf(out4,"<TD><CENTER>%d</CENTER></TD>",0);
				fprintf(out5,"<TD><CENTER>%d</CENTER></TD>" ,0);
				fprintf(out6,"<TD><CENTER>%d</CENTER></TD>" ,0);
				fprintf(out7,"<TD><CENTER>%d</CENTER></TD>" ,0);
				fprintf(out8,"<TD><CENTER>%d</CENTER></TD>" ,0);
			}
			else{
				fprintf(out2,"<TD><CENTER>%d</CENTER></TD>",
				seats[i][j].agentID);

				fprintf(out3,"<TD><CENTER>%d</CENTER></TD>",
				 
					agents[seats[i][j].agentID].locPref[0]);
				fprintf(out4,"<TD><CENTER>%d</CENTER></TD>",
			 
					agents[seats[i][j].agentID].locPref[1]);
				fprintf(out5,"<TD><CENTER>%d</CENTER></TD>",
			 
					agents[seats[i][j].agentID].locPref[2]);
				fprintf(out6,"<TD><CENTER>%d</CENTER></TD>",
				 
					agents[seats[i][j].agentID].locPref[3]);
				fprintf(out7,"<TD><CENTER>%d</CENTER></TD>",
				 
					agents[seats[i][j].agentID].pref[0]);
				fprintf(out8,"<TD><CENTER>%d</CENTER></TD>",
				 
					agents[seats[i][j].agentID].solitude);
			}
	
		}
		fprintf(out2,"<TR>\n");
		fprintf(out3,"<TR>\n");
		fprintf(out4,"<TR>\n");
		fprintf(out5,"<TR>\n");
		fprintf(out6,"<TR>\n");
		fprintf(out7,"<TR>\n");
		fprintf(out8,"<TR>\n");
	}
}

float GetRand()
{
	return (float)rand()/(float)RAND_MAX;
}