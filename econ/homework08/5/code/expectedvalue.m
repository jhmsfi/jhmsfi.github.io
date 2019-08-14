function[out]=expectedvalue(state,person,dist) 

marg=marginal(state,dist,person);
out=distance(state,person);

out=out.*marg;
out=sum(sum(out));