function[total]=main(in) 

iterations=250;
N=100;     %total floors
rho=.1;   %probability of button

rows=10;
columns=15;
peopleminrows=2;
peoplemaxrows=5;
peoplemincolumns=2;
peoplemaxcolumns=5;

floors=randsample([1:100],1);
state=zeros(rows,columns);
dist=distribution(rows,columns);
total=zeros(10,15);
m=0;
for k=1:iterations
  k
  newfloors=[];
  for j=max(floors):-1:1
    I=floors==j;
    for l=1:sum(I)
      person.rows=randsample([2:peoplemaxrows],1);
      person.columns=randsample([1:peoplemaxcolumns],1);
      choice=agentdown(state,j,person,dist);
      m=m+1;
      I=state==0;
      percentage=sum(sum(I))/sum(sum(I*0+1));
      data(m,:)=[k j choice percentage person.rows person.columns person.rows*person.columns];
      if choice==1
        state=updatestate(state,dist,person);
        hold on
        %plotstate(state) 
        %pause
      end 
    end
    
    if rand<rho
      thisfloor=randsample([1:100],1);
      riders=randsample([1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 3 3 4 5],1);
      if thisfloor<j
        for n=1:riders
        floors=[floors thisfloor];
        end
      else;
        for n=1:riders
          newfloors=[newfloors thisfloor];
        end
      end
    end
  end
  

    
  if length(newfloors)==0
    for k=1:1000
      if rand<rho
        floors=randsample([1:100],1);
      end
      break;
    end
  else 
    floors=newfloors;
  end  
  I=state==2;
  total=total+I
  state=zeros(rows,columns);
  %close all
end
