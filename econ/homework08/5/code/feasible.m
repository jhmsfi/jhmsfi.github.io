function[out]=feasible(state,person)

for k=1:person.columns-1
  state(:,k)=ones(length(state(:,1)),1)*3;
end

for k=length(state(:,1)):-1:length(state(:,1))-person.rows+2
  state(k,:)=ones(length(state(1,:)),1)*3;
end

out=state==0;
