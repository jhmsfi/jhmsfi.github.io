
function [output] = optimaster(n, strat, penalty)
	% This is the main function to call the adaptive algorithm.
	% n = 8 number of individuals getting on the elevator.
	% strat = starting vector of strategies.
	% penalty = the time penalty experienced by passangers for moving back
	% Outputs a vector of the amount of time for each rider
	% after 1,000 adaptive stages, and the final strategy vector.

	for i = 1:n

		x(i,1) = i; % each pasanger is assinged their floor
	end


	oldticker = submaster(x,strat,penalty); 
		% ride elevator under initial conditions


	for runs = 1:1000

		z = rand(1,2); 
		updater = ceil(n*z(1));% choose a random rider
		old = strat(updater); % store outcome from last ride
		new = ceil(3*z(2));   % have rider choose new floor
		
		strat(updater) = new; % Add it into strat vector

		newticker = submaster(x,strat,penalty); 
		%% Ride the elevator again
		
		if newticker(updater) < oldticker(updater)
    			oldticker = newticker;
		else
   			 strat(updater) = old;
		end
		%% If it took less time with the new strategy,
		%% accept the new strategy.  Otherwise reject.
	
	end

	output = [newticker, strat];
	


