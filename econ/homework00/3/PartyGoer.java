class PartyGoer {

	private static final double NEIGHBOR_FACTOR = .7;  // group attractiveness
	public static final int MAX_TIME_DISCOUNT = 15;  // controls sensitivity to getting bored
	public static final int MAX_LIKES = 10;          // maximum affinity another holds to PartyGoer
	public static final int TIME_FACTOR = 5;
	public static final double NORMALIZED_MAX_LIKES_MEAN = 0.7;
	
	private int ID; 						// agents ID in the room grid
	private int Likes[] = new int[Room.NUMBER_PARTIERS];		// affinity array
	private double V[][] = new double[Room.YSPOTS][Room.XSPOTS];    // value matrix
	private int TimeDiscount[] = new int[Room.NUMBER_PARTIERS];     // amount others bore you
	private int LocationX=0;
        private int LocationY=0;

        private static java.util.Random rnd = new java.util.Random();

	// accessors
	public int getAgentX() { return (LocationX); }
	public int getAgentY() { return (LocationY); }

	PartyGoer(int[][] Grid, int pID) {
		int FoundSpot = 0;
	
	        ID = pID;
		for(int i=1; i < Room.NUMBER_PARTIERS; i++)
                        Likes[i] = (int)((rnd.nextDouble()-0.5+(NORMALIZED_MAX_LIKES_MEAN))
                        						*2*PartyGoer.MAX_LIKES);

                while(FoundSpot == 0) {
                	LocationX = (int)(rnd.nextDouble()*Room.YSPOTS);
                	LocationY = (int)(rnd.nextDouble()*Room.XSPOTS);
			if (Grid[LocationX][LocationY] == 0) {
				Grid[LocationX][LocationY] = ID;
				FoundSpot = 1;
			}
	       }
	}
	
	public void setLikes (int p, int v) { Likes[p] = v; }
	public void setX (int newX) { LocationX = newX; }
	public void setY (int newY) { LocationY = newY; }

	
	// used to get information from the room about other agent's positions
	private int[] getOtherAgentPosition(int a, int[][] Grid) {
                int[] L = new int[2];
                for(int i=1; i < Room.YSPOTS; i++)
                        for(int j=1; j < Room.XSPOTS; j++) {
                                if(Grid[i][j]==a) {
                                     L[0] = i;
                                     L[1] = j;
                                }
                        }
                return L;
        }

        // only called by CalculateValues
	// used to calculate the value contribution to this agent
	// from agent p, using Likes, neighbors, and a time component
        private double CalculateIndividualSpacialValue(int p, int[][] Grid, int PropI, int PropJ) {
            double v = 0;
            double dx=0, dy=0;
	    double discount, neighborx=0, td=0;
	    int[] L;
	    int tp;

	    if (p != ID) {
        	// find the distance to agent p
        	L = getOtherAgentPosition(p, Grid);
        	dx = (double)(L[0] - PropI);
		dy = (double)(L[1] - PropJ);
        	discount = 1/(Math.pow(dx,2) + Math.pow(dy,2));
	
		// add value for number of people around p
		// subtract value for the time-discounting (as people get boring)
        	for (int i=L[0]-1;i<=L[0]+1;i++)
		    for (int j=L[1]-1;j<=L[1]+1;j++) {
			if( (i < Room.YSPOTS) && ( j < Room.XSPOTS) && (i >= 0) && (j >= 0) ) {
			    tp = Grid[i][j];
                            if (tp != ID && tp != p) {
                        	neighborx += NEIGHBOR_FACTOR*Likes[tp] - TimeDiscount[tp];
		            }
		         }
		    }
	        v = discount*(Likes[p] + neighborx - TimeDiscount[p]);
	    }
	    else { v = 0; }
	    return v;
	}
	
	// calculates the values of all grid-points
	private void CalculateValues(int[][] Grid) {
		
	    for (int i=0;i<Room.YSPOTS;i++)
		for (int j=0;j<Room.XSPOTS;j++) {
		    // calculate the values of each spot by summing
		    // over the sum of distance-discounted values
		    // of speaking with each individual in the room
		    V[i][j] = 0;
		    for (int p=1; p<Room.NUMBER_PARTIERS; p++) { // 0 is not an agent
			if (p != ID) V[i][j] += CalculateIndividualSpacialValue(p, Grid, i, j);
		    }
		}
	}
	
	private void DecayNeighbors(int[][] Grid) {
	        int i, j, tp;
	
		// update time-decaying value of proximity with current neighbors
                for(i = LocationX-1; i <= LocationX+1; i++)
                    for(j = LocationY-1; j <= LocationY+1; j++) {

                        if ((i < Room.YSPOTS) && (j < Room.XSPOTS) && (i >= 0) && (j >= 0) ) {
                            tp = Grid[i][j];
                            if (tp != ID) {
                        	// add two to the discount, because we subtract one from everyone below
                                if (TimeDiscount[tp] < MAX_TIME_DISCOUNT) TimeDiscount[tp] += 2*TIME_FACTOR;
                            }
                        }
                    }

                for(i=0; i < Room.YSPOTS; i++)
                    for(j=0; j < Room.XSPOTS; j++) {
                        tp = Grid[i][j];
                        if (tp != ID) {
                        	if (tp > 0 && TimeDiscount[tp] > 0) TimeDiscount[tp] -= TIME_FACTOR;
                        }      
                    }
	
	}
	
	public void Move(int[][] Grid) {
		double MaxVal = V[LocationX][LocationY];
		int NewM[] = {LocationX, LocationY};
		int i,j;
		
		DecayNeighbors(Grid);
				
		CalculateValues(Grid);
		for(i = LocationX-1; i <= LocationX+1; i++)
		    for(j = LocationY-1; j <= LocationY+1; j++) {
			if ((i < Room.YSPOTS) && (j < Room.XSPOTS) && (i >= 0) && (j >= 0) ) {
			    if (Grid[i][j] == 0) { // it's a valid move & unoccupied
				if (V[i][j] > MaxVal) {
					MaxVal = V[i][j];
					NewM[0] = i;
					NewM[1] = j;
				}
			    }
			}
		    }
		
		if (LocationX != NewM[0] || LocationY != NewM[1]) { // we will move
		    Grid[LocationX][LocationY] = 0;		
		    LocationX = NewM[0];
		    LocationY = NewM[1];
		    Grid[LocationX][LocationY] = ID;
		}
	}

}
