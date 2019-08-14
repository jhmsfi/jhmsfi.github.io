% Airport Lounge Model
clear;

N=100; % number of agents
time_update = 3; %Default entry frequency
agents = zeros(6, N); %Create matrix with agent parameters
agents(4,:) = randperm(N); %Create random IDs

for run=1:100 %Evolution of preferences

agents(1,:) = rand(1,N); %Create line tolerance 

%Make a copy of preferences and waiting times to be used in evolution
agents(5,:)=agents(1,:); %Old line tolerance
agents(6,:)=agents(2,:); %Old waiting time

agents(3,:) = ones(1,N); %Indicates if still waiting
agents(2,:) = zeros(1,N); %Waiting times will be stored here

%Initialize
line_len = 0; %length of line
que = []; %line vector
time_tic=1;
test=0; %test the delay caused by wrong order

while any(agents(3,:))
  % pick agent at random from people in the waiting area
  i=ceil(N*rand(1,1));
  if agents(3,i)==1 
      if agents(1,i) > line_len/N % join line
          agents(3,i) = 0;
          agents(2,i) = agents(2,i)+line_len*time_update;
          line_len = line_len + 1;
          que = [que agents(4,i)];
      end
           % all agents inside waiting
           for col=1:N
              if agents(3,col)==1 agents(2,col)=agents(2,col)+1; end; 
           end;
      time_tic=time_tic+1;
      line_vec(1,time_tic) = line_len;
      
      %Enter the plane
      if mod(time_tic,time_update)==0
          if test==10
              que=que(1,2:end);
              line_len=line_len-1;
              test=0;
          end;
          if length(que)>1 
              if que(1,1)>que(1,2)
                  test=test+1; 
              else
                  que=que(1,2:end);
                  line_len=line_len-1;
              end;
          else
              line_len=line_len-1;
              que=[];
          end;
     end;
  end; %pick agent from the waiting area
end; %while

%Evolve preferences
if run>1
 for a=1:N
    if agents(2,a)>agents(6,a) agents(1,a)=agents(5,a); end;
 end;
end;

end; % main for loop

%Print out results
figure(1);
plot(line_vec);
xlabel('Time');
ylabel('Line length')
title('Line length vs. time to board')
figure(2);
time_bar=mean(agents(2,:))
hist(agents(2,:))
xlabel('Waiting Time');
ylabel('Density');
title('Individual waiting time distribution');