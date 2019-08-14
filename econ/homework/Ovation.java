/*
 *	Ovation -- A Java-based Standing Ovation Simulator. 
 *	Copyright (C) 1996 Thor Sigvaldason
 *
 *
 *	based on a
 *	model and
 *	C code  
 *	developped by:	Kim-Sau Chung
 *			Carl Hirschman
 *			Thor Sigvaldason
 *			Matt Weagle
 *
 *		   at:	The 1996 Graduate Workshop in Computational Economics
 *			Santa Fe Institute
 *			Santa Fe, New Mexico
 *
 *
 *	This program is free software; you can redistribute it and/or modify
 * 	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 2 of the License, or
 *	(at your option) any later version.
 *	
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *	
 *	You should have received a copy of the GNU General Public License
 *	along with this program; if not, write to the Free Software
 *	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 */


import java.applet.*;		// Standard necessary file for applets
import java.awt.*;		// For graphical output
import java.util.*;		// Need a random number generator
	

//
//  This is the ``main'' routine which is run when the applet is first loaded.
//  It initializes the audience (as an array of Audience objects) and the
//  speaker, and then waits for the user to select the start button.
//


public class Ovation extends Applet implements Runnable
{
	
	//
	//	Constants (like C #defines)
	//
	//

	public static final int NUMB_ROWS = 20;		// Rows in Auditorium 
	public static final int NUMB_COLS = 30;		// Columns in Auditorium
	public static final int H_OFFSET = 3;		// Visual Offsets for Display on Web Page
	public static final int V_OFFSET = 32;		// "                                    "
	public static final int TIMER = 50;		// Time delay on redraws (sleep value)
	public static final int PSIZE = 10;		// Size of each Seat in Pixels
	public static final int VISION = 3;		// How many rows ahead they see
	static Random rando = new Random();             // Random Number Generator 
	

	//
	//	Variables
	//

	int 		i,j,k;				
	public 		int numb_rows = NUMB_ROWS;	
	public 		int numb_cols = NUMB_COLS;
	public 		Audience the_audience[][] = new Audience[numb_rows][numb_cols];
	public 		Speaker the_speaker = new Speaker();
	boolean 	ok_start;

	//
	//	Graphic Elements
	//

	Panel  	 	all_buttons;		// Panel to hold the buttons
	Button 	 	start_button;		//  \
	Button 	 	stop_button;		//  |
	Button 	 	rand_speaker;		//  > Self explanatory buttons
	Button 	 	rand_audience;		//  |
	Button 	 	rand_both;		//  |
	Button 	 	evolve;			//  /
	Canvas		space_waste;		// Space for the actual auditorium to be drawn
	
	//
	//	Initialize
	//	
	//

	public void init()
	{
		//
		//	Create the audience as an array
		//
		for(i=0; i < numb_rows; i++)
		{
			for(j=0; j < numb_cols; j++)
			{
				the_audience[i][j] = new Audience(i,j);
			}
		}
		ok_start = false;	// Don't start out running by default
		//
		//	Set up the graphical elements
		//
		all_buttons = new Panel();
		all_buttons.setLayout(new GridLayout(3,2,5,5));
		start_button = new Button("Start");
		stop_button = new Button("Stop");
		rand_speaker = new Button("Shake Speaker");
		rand_audience = new Button("Shake Audience");
		rand_both = new Button("Shake Both/Reset");
		evolve = new Button("Evolve");
		all_buttons.add(start_button);
		all_buttons.add(stop_button);
		all_buttons.add(rand_speaker);
		all_buttons.add(rand_audience);
		all_buttons.add(rand_both);
		all_buttons.add(evolve);

		space_waste = new Canvas();

		this.setLayout(new BorderLayout(0,0));

		this.add("Center", space_waste);
		this.add("South",all_buttons);
		stop();
	}
	//
	//	What happens when an event happens
	//	(ex. the mouse pushes the start button)
	//

	public boolean action(Event event, Object arg)
	{
		if(event.target == start_button)
		{
			ok_start = true;
			start();
			return true;
		}
		if(event.target == stop_button)
		{
			stop();
			return true;
		}
		if(event.target == rand_speaker)
		{
			the_speaker.randomize();
			return true;			
		}
		if(event.target == rand_audience)
		{
			for(i = 0; i < numb_rows; i++)
			{
				for(j = 0; j < numb_cols; j++)
				{
					the_audience[i][j].randomize();
				}
			}
			return true;
		}
		if(event.target == rand_both)
		{
			for(i = 0; i < numb_rows; i++)
			{
				for(j = 0; j < numb_cols; j++)
				{
					the_audience[i][j].randomize();
				}
			}
			the_speaker.randomize();
			return true;
		}
		if(event.target == evolve)
		{
			//Send e-mail to Brian Arthur ?
			return true;
		}
		else return super.action(event,arg);
	}


	//
	//	How to stop() and start() the simulation 
	//

	public Thread the_simulation = null;

	public void start()
	{
		if(the_simulation == null)
		{
			the_simulation = new Thread(this);
			the_simulation.start();
		}
	}

	public void stop()
	{
		if((the_simulation != null) && the_simulation.isAlive())
		{
			the_simulation.stop();
		}
		the_simulation = null;
	}

	//
	//	This is the thread that actually runs the simulation
	//
	public void run()
	{
		int clock_ticks = 0;		// Within stage game time periods
		int numb_standing = 0;		// Number standing each clock tick
		int max_numb_standing = 0;	// Maximum standing during a single stage game
		boolean allsit;			// Did everyone fail to stand up?
		while (ok_start == true)
		{

			//
			//	Draw the outline of the stage and the speaker's platform
			//

			Graphics g = space_waste.getGraphics();
			g.setColor(Color.black);
			g.drawRect(H_OFFSET - 1 , V_OFFSET - 1 , numb_cols * PSIZE + 2, numb_rows * PSIZE + 2);
			g.drawRect(H_OFFSET - 1 , V_OFFSET - (PSIZE * 3) - 1, numb_cols * PSIZE + 2, PSIZE + 1);

			//
			//	Draw the colour spectrum between the speaker and the audience
			//
	
			for(i = 0; i < 100; i++)
			{
				Color e = new Color(50, 50, 50 + (i * 2));
				g.setColor(e);
				g.fillRect(H_OFFSET + Math.round((1/100) * (numb_cols - 1) * PSIZE) + (i * 3), V_OFFSET - (PSIZE * 2) + 5, 3, PSIZE);
			}
			
			//
			//	Erase the inside of the speaker's platform to wipe out whatever his last
			//	position was.
			//

			g.setColor(this.getBackground());
			g.fillRect(H_OFFSET, V_OFFSET - (PSIZE * 3), numb_cols * PSIZE, PSIZE);

			//
			// 	Draw the speaker's current position as a thin rectangle
			//

			Color c = new Color(50, 50, 50 + Math.round(the_speaker.position * 200));
			g.setColor(c);
			g.fillRect(H_OFFSET + Math.round(the_speaker.position * (numb_cols - 1) * PSIZE), V_OFFSET - (PSIZE * 3), 3, PSIZE);

			//
			//	Draw each audience member with appropriate colour if standing and 
			//	in the background colour if sitting
			//

			for(i=0; i < numb_rows; i++)
			{
				for(j=0; j < numb_cols; j++)
				{
					if(the_audience[i][j].response == true)
					{
						Color d = new Color(50, 50, 50 + Math.round(the_audience[i][j].want * 200));
						g.setColor(d);
						g.fillRect(H_OFFSET + j*PSIZE, V_OFFSET + i*PSIZE, PSIZE - 2 , PSIZE - 2 );
					}
					else
					{
						g.setColor(this.getBackground());
						g.fillRect(H_OFFSET + j*PSIZE, V_OFFSET + i*PSIZE, PSIZE - 2 , PSIZE - 2 );
					}
				}
			}

			//
			//	Make sure the graphics have been drawn and then sleep for
			//	a few milliseconds
			//

			this.getToolkit().sync();
			try{ Thread.sleep(TIMER);} catch (InterruptedException e);


			//
			//	Before anyone changes position, how many paople
			//	can I see standing?
			//

			int left, right, up, across;
			int depth;
			for(i = 0; i < numb_rows; i++)
			{
				for(j=0; j < numb_cols; j++)
				{
					depth = i - VISION;
					if(depth < 0) depth = 0;
					the_audience[i][j].isee = 0;
					for(up = i - 1; up >= depth; up--)
					{
						left = j - (i - up);
						right = j + (i - up);
						if(left < 0)
						{
							 right = right + Math.abs(left);
							 left = 0;
						}
						if(right > numb_cols) 
						{
							left = left - (right - numb_cols);
							right = numb_cols;
						}
						for(across = left; across < right; across++)
						{
							if(the_audience[up][across].response == true) the_audience[i][j].isee++;
						}
					}

				}
			}
			
			//
			//	Now we can update everyone's sit/stand decision
			//

			allsit = true;
			numb_standing = 0;
			for(i = 0; i < numb_rows; i++)
			{
				for(j=0; j < numb_cols; j++)
				{
					if(the_audience[i][j].calculate_response(clock_ticks, the_speaker.position) == false)
					{
						allsit = false;
						numb_standing++;
					}
				}
			}

			//
			//	Check and see if the number standing this time click is a
			//	stage game maximum
			//

			if(numb_standing > max_numb_standing)
			{
				max_numb_standing = numb_standing;
			}

			//
			//	If everyone is sitting, then the stage game is over, so the
			//	speaker and the audience have to be updated
			//
		
			if(allsit == true)
			{

				//
				//	Update the audience
				//
				//	NB:	This updating is different from the original algorithm
				//		described in the paper. Here, we just move through a row
				//		and see if the person sitting behind you enjoyed the
				//		message more than you did. If so, switch places.
				//

				clock_ticks = 0;
				float temp;
				for(i = 0; i < numb_cols; i++)
				{
					for(j = 0; j < numb_rows  - 1; j++)
					{
						if(Math.abs(the_audience[j][i].want - the_speaker.position) > 
						   Math.abs(the_audience[j + 1][i].want - the_speaker.position))
						{
							temp = the_audience[j+1][i].want;
							the_audience[j+1][i].want = the_audience[j][i].want;
							the_audience[j][i].want = temp;
						}
					}
				}

				//
				//	Now we randomly shuffle people around within a given row to
				//	to allow people to move left/right (the updating algorithm
				//	above always leaves agents in the same column).
				//

				for(i = 0; i < numb_rows; i++)
				{
					for(j = 0; j < numb_cols - 1; j++)
					{
						if(rando.nextFloat() < 0.1)
						{
							temp = the_audience[i][j].want;
							the_audience[i][j].want = the_audience[i][j+1].want;
							the_audience[i][j+1].want = temp;
						}
					}
				} 

				//
				//	Simple speaker learning
				//

				the_speaker.learn(max_numb_standing);
				max_numb_standing = 0;
			}
			else
			{ 
				clock_ticks++;		// If we got here, then we're still within a stage game
			}
		}	
	}
}

//
//	The audience class from which the array of audience members is built
//
class Audience 
{
	//
	//	Need some static variables
	//

	static Random rando = new Random();             // Rabdomly assign wants
	static final double DECAY       = 0.012;	// Decay Rate to Standing
	static final double THETA       = 0.090;	// Basic Utility to Standing
	static final double CONF_WEIGHT = 0.045;	// Weight on conformity utility

	//
	//	Variables that each audience member possesses
	//

	public float	want;			// Each member's preferred message
	public int	isee;			// People I can see standing
	public int	rownumb;		// Row location in auditorium
	public int	colnumb;		// Column location in auditorium
	public boolean	response;		// Sit (= false) or Applaud (= true)

	//
	//	Method declarations
	//

	// 
	//	Constructor:
	//

	public Audience(int assignedrow, int assignedcol)
	{
		rownumb = assignedrow;		// Tell me my row number
		colnumb = assignedcol;		// and what seat?
		want = rando.nextFloat();	// Randomly assign my preferred message
		response = false;		// Start out sitting
		isee = 0;			// People I see standing
	}

	//
	//	Randomize agents (all we have to do is reset their preferred message)	
	//

	public void randomize()
	{
		want = rando.nextFloat();
	}

	//
	//	Calculate utility to standing and then stand if it's greater than 0
	//	(this is exactly as described in the paper)
	//

	public boolean calculate_response(int period, double message)
	{
		double utility = THETA;
		utility = utility - (DECAY * period);
		utility = utility - Math.abs(want - message);
		utility = utility + (CONF_WEIGHT * isee);
		response = false;
		if(utility > 0)
		{
			response = true;
			return false;
		}
		else
		{
			return true;
		}
	}

}

class Speaker
{
	//
	//	There is only one instance of this class; the_speaker
	//

	static Random rando = new Random();		// Start with random message 
	static final double MOVE_DISTANCE = 0.03;	// How far to move each update

	public float position;				// Message Delivered by speaker
	public int   move;				// Last Direction movement
	public int   last_standers;			// How many people stood last lecture
	
	//
	// Constructor:
	//

	public Speaker()
	{
		double temp;
		position = rando.nextFloat();
		temp = rando.nextFloat();
		if( temp < 0.5)
		{
			move = -1;
		}
		else
		{
			move = 1;
		}
		last_standers = 0;
	}

	//
	//	Randomly reset the speaker's position
	//

	public void randomize()
	{
		position = rando.nextFloat();
	}

	//
	//	Update the speaker's position
	//	(ie. keep moving in the same direction as long as the
	//	 ovation response from the audience keeps growing)
	//

	public void learn(int standers)
	{
		if(standers < last_standers)
		{
			move = (0 - 1) * move;	
		}
		position = position + move * (float)MOVE_DISTANCE;
		if(position < 0) position = 0;
		if(position > 1) position = 1;
		last_standers = standers;
	}
}