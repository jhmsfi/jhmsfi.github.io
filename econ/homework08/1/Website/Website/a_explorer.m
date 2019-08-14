% n = number of arrivals. NOTE: <= 9
% penalty represents the confusion penalty for everone moving back at once
% strat is the initial strategy set used to begin the adaptive algorithm.
%% Note: make sure this is of length n
%% This function runs the main adaptive algorithm 100 times.
%% outputs a vector of initial conditions
%% output(1) = n from the call
%% output(2) = p from the call
%% output(3) = mean number of 1's in the resulting adaptive strategy.
%% output(4) = variance in the number of 1's in the resutling adaptive strategy.
%% output(5) = mean number of 2's in the resulting adaptive strategy.
%% output(6) = variance in the number of 2's in the resutling adaptive strategy.
%% output(7) = The mean of the average time it took to get of the elevator
%%%%%%%%%%%%%% for the final adaptive strategy.
%% output(8) = The variance of the average time it took to get of the elevator
%%%%%%%%%%%%%% for the final adaptive strategy.
%% output(9) = The mean of the total time for the elevator ride in the res. strat.
%% output(10) = The mean of the total time for the elevator ride in the res. strat.

function [output] = a_explorer(n, strat,penalty)
	% instantiate some variables
	A = []; % a matrix to store the strategy history, if you want to output that
	averate_t=[]; %
	total_t=[];
	k = n;
	ones = [];
	twos = [];

  	for r = 1:100 % run the adaptive algorithm 100 times, and store outputs
                            
		temp = masteradaptive(n, strat, penalty); % run the main adaptive file.
		average_t(1, r) = mean(temp(1:k, 1));
		total_t(1,r) = max(temp(1:k, 1));
		A (1:k, r) = temp(1:k, 2);


	end
     
    

	for j = 1:r; % pull out the number of 1's and 2's in the results
		ones(1,j) = 0;
		twos (1,j)=0;
		for i = 1:k;
    			if A(i,j) == 1
    				ones(1, j) = ones(1,j) + 1;
			elseif A(i,j) == 2
				twos(1, j) = twos(1,j) + 1;
			end
		end
	end

output = [n, penalty, mean(ones), var(ones), mean(twos), var(twos), mean(average_t), var(average_t), mean(total_t), var(total_t)]
