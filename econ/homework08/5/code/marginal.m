function[marg]=marginal(state,dist,person)

feas=feasible(state,person);
marg=feas.*dist;
if sum(sum(marg))==0
  marg=marg*0;
else 
  marg=marg/sum(sum(marg));
end
