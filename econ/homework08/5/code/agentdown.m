function[choice]=agentdown(state,start,person,dist)

frequency=1/5;   %frequency of stops
c=.25;     %disulitiy of stopping at floor;
d=.06;     %disutiilyt walking down one floor;
e=.3;     %disutility of being close to others;


expectedstops=start*frequency;
utilityelevator=1-c*expectedstops-e*expectedvalue(state,person,dist);
utilitystairs=.5-d*start;

if sum(sum(state))==0
  utilityelevator=1-c*expectedstops;
end




utilityelevator;
utilitystairs;

if utilitystairs>utilityelevator
  choice=0;  
elseif utilitystairs<utilityelevator
  choice=1;
end


feas=feasible(state,person);
if sum(sum(feas))==0
  choice=0;
end

  
