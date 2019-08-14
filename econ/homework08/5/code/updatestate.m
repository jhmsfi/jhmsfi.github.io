function[state]=updatestate(state,dist,person)


marg=marginal(state,dist,person);

thissum=0;
thisrand=rand;
for row=1:length(marg(:,1))
  for column=1:length(marg(1,:))
    thissum=thissum+marg(row,column);
    if thissum>thisrand
      newrow=row;
      newcolumn=column;
      thissum=-10e100;
      for row=newrow:newrow+person.rows-1
        for column=newcolumn-person.columns+1:newcolumn
          state(row,column)=2;
        end
      end
    end
  end
end

for row=1:length(state(:,1))
  taken=0;
  for column=1:length(state(1,:))
    if state(row,column)==2
      taken=1;
    end
    if taken>0 && state(row,column)==0
      state(row,column)=1;
    end
  end
end

for column=1:length(state(1,:))
  taken=0;
  for row=length(state(:,1)):-1:1
    if state(row,column)>0
      taken=1;
    end
    if taken>0 && state(row,column)==0
      state(row,column)=1;
    end
  end
end


  
