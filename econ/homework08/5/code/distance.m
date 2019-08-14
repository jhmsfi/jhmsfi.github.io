function[out]=distance(state,person)



feas=feasible(state,person);

people=state==2;
out=zeros(length(people(:,1)),length(people(1,:)));
for feasiblerow=1:length(people(:,1))
  for feasiblecolumn=1:length(people(1,:))
    if feas(feasiblerow,feasiblecolumn)==1
      mindist=10e100;
      for currentrow=feasiblerow:feasiblerow+person.columns-1
        for currentcolumn=feasiblecolumn-person.rows+1:feasiblecolumn
          for row=1:length(people(:,1))
            for column=1:length(people(1,:))
              if people(row,column)==1
                thisdist=((currentrow-row)^2+(currentcolumn-column)^2)^.5;
                if thisdist<mindist
                  mindist=thisdist;
                  minrow=row;
                  mincolumn=column;
                end
              end
            end
          end
        end
      end
      out(feasiblerow,feasiblecolumn)=mindist;
    end
  end
end
