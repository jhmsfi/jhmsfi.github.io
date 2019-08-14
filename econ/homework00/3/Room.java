public class Room {

        public final static int XSPOTS = 15;
        public final static int YSPOTS = 15;
	public static final int NUMBER_PARTIERS = 22;
        public static final int ITERATIONS = 100;
	
	private PartyGoer[] pga = new PartyGoer[NUMBER_PARTIERS];

	public int[][] Grid = new int[YSPOTS][XSPOTS];
	

	public static void main(String[] args) {
		int i, t;
		int NewM[] = new int[2];
                int OldM[] = new int[2];
		
		Room r = new Room();
		
		for (i=1; i < NUMBER_PARTIERS; i++)
			r.pga[i] = new PartyGoer(r.Grid, i);
		
		// run the simulation
                t = 0;		
                corejava.Format.printf("t = %i", t);
                System.out.println("");
                TextInterface.ShowRoom(r.Grid);

                while(t < ITERATIONS) {
                    t++;

                    for(i=1; i<NUMBER_PARTIERS; i++)
                        r.pga[i].Move(r.Grid);

                    corejava.Format.printf("t = %i\n", t);
                    TextInterface.ShowRoom(r.Grid);
                }
        }
}
