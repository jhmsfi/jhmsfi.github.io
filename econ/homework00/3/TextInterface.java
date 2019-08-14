public class TextInterface {

	public static void ShowInts(int[] ints, int n) {
		for(int i = 0; i<n;i++)
			corejava.Format.printf("%i ", ints[i]);
		System.out.println(" ");
	}

	public static void ShowRoom(int[][] Grid) {
		
		for(int i=0; i < Room.YSPOTS; i++) {
			for(int j=0; j<Room.XSPOTS; j++) {
				if (Grid[i][j] == 0) System.out.print("__.");
				else corejava.Format.printf("%02i.", Grid[i][j]);
			}
			
			System.out.println(" ");
			
		}
		System.out.println(" ");
	}

}
