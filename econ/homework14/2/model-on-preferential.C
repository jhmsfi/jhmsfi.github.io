#include <iostream>
#include <stdlib.h>
using namespace std;
int binrand(double rho); // binary random number, returns 1 with probability rho, 0 else
int randint(int min, int max); // gives a uniform random integer between min and max
int randarray(double prob[], int outputs[], int size); // gives output from the vector `outputs[]' randomly with probabilities `prob[]'



main()
	{
	// Model parameters
	const int N = 10000;
	const double q = 0.5;
	const double ca = 0.3;
	const double cb = 0.5;
	
	// behaviour vector of the individuals
	int behave[N]={0};
	
	const int indegree = 10;

	const int friendssetsize=1000;
	int **friends;
	friends = new int *[N];
	for(int i=0; i<N; i++) friends[i] = new int[friendssetsize];
	
	unsigned int k[N]={0};

	
	const int types=5;	
	
	const int iterations = 200*N;
	int amount[types]={0};
	amount[1]=1;


	const int initialtypes=3;
	double prob[]={0.2,0.45,0.35};
	int typeorder[]={2,0,4};

	// Initial  condition	
	for(int i=0; i<N; i++) for(int j=0; j<friendssetsize; j++) friends[i][j]=N;
	for(int i=0; i<indegree; i++){ for(int j=0; j<indegree; j++) friends[i][j]=j; k[i]=indegree; }
	
	for(int n1=indegree; n1<N; n1++)
		{
		for(int n2=0; n2<indegree; n2++)
			{
			int size=n1-1;
			int *friendchoices;
			friendchoices = new int[size];
			for(int i=0; i<size; i++) friendchoices[i] = i;
			double *probabilities;
			probabilities = new double[size];
			double totaldegree=0.L;
			for(int i=0; i<size; i++){ probabilities[i]=(double)k[i]; totaldegree+=(double)k[i]; }
			for(int i=0; i<size; i++){ probabilities[i] = probabilities[i]/totaldegree; }
			int n3 = randarray(probabilities,friendchoices,size);
			
			friends[n1][k[n1]]=n3; k[n1]++;
			friends[n3][k[n3]]=n1; k[n3]++;
			
			delete friendchoices;
			delete probabilities;
			}
		
		
		}
	
	
	
	
	
	// behavior  P = 0, A1 = 1, A2 = 2, B1 = 3, B2 = 4

	behave[0] = 1;

	for(int i=1; i<N; i++)
		{ 
		int behavior = randarray(prob,typeorder,initialtypes); 
		behave[i] = behavior; 
		amount[behavior]++;

/*		if(binrand(q)==1)
			{ 
			behave[i] = 2; 
			amount[2]++;
			}
		else 
			{
			behave[i] = 4; 
			amount[4]++;
			}
*/		}
	

	for(int iterate=0; iterate<iterations; iterate++)
		{
		int n1 = randint(0,N-1);
		int n2 = randint(0,k[n1]-1);
		n2 = friends[n1][n2];
		
		if(behave[n1]==1&&behave[n2]==2)	 { behave[n2]=1; amount[2]--; amount[1]++; }
		else if(behave[n1]==2&&behave[n2]==1){ behave[n1]=1; amount[2]--; amount[1]++; }
		
		else if(behave[n1]==0&&behave[n2]==1){ if(binrand(ca)==1){ behave[n1]=1; amount[0]--; amount[1]++; }}
		else if(behave[n1]==1&&behave[n2]==0){ if(binrand(ca)==1){ behave[n2]=1; amount[0]--; amount[1]++; }}

		else if(behave[n1]==1&&behave[n2]==4){ behave[n2]=3; amount[4]--; amount[3]++; }
		else if(behave[n1]==4&&behave[n2]==1){ behave[n1]=3; amount[4]--; amount[3]++; }
		
		else if(behave[n1]==1&&behave[n2]==3)
			{
			if(binrand(cb)==1)
				{
				behave[n1]=0; amount[1]--; amount[0]++;
				}
			} 
		else if(behave[n1]==3 && behave[n2]==1)
			{ 
			if(binrand(cb)==1)
				{
				behave[n2]=0; amount[1]--; amount[0]++; 
				}
			}
		
		// in case of asymmetric information	
		else if(behave[n1]==2&&behave[n2]==3){ behave[n1]=1; amount[2]--; amount[1]++; }
		else if(behave[n1]==3&&behave[n2]==2){ behave[n2]=1; amount[2]--; amount[1]++; }	
			
		else if(behave[n1]==3&&behave[n2]==4){ behave[n2]=3; amount[4]--; amount[3]++; }
		else if(behave[n1]==4&&behave[n2]==3){ behave[n1]=3; amount[4]--; amount[3]++; }
		
		
		
		
		
		if(iterate%100==0)
			{
//			int count[types]={0};
//			for(int i=0; i<N; i++){ count[behave[i]]++; } 

			cout << iterate/(double)N; for(int i=0; i<types; i++) cout << '\t' << amount[i]/(double)N; cout << endl; 

//			for(int i=0; i<N; i++) cout << behave[i] << ' '; cout << endl;
			}
		
		}	
	
	
	
	for(int i=0; i<N; i++) delete friends[i];
	delete friends;
	
	}
	
int binrand(double rho)
  {
  int result=0; double x=0.;
  x = rand()/(double)RAND_MAX;
  if(x<rho) result = 1;
  return result;
  }

int randint(int min, int max)
  {
  return (int)((double)rand()*(max+1-min)/((double)RAND_MAX+1.0) + min);
  }

int randarray(double prob[], int outputs[], int size)
	{
	double x=0.;
	int result=0;
	x = rand()/(double)RAND_MAX;
	double probsum=0.;
	for(int i=0; i<size; i++)
		{
		probsum+=prob[i];
		if(x<probsum){ result=outputs[i]; break;}
		}
	return result;
	}
