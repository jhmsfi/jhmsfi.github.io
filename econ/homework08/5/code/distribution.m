function[out]=distribution(rows,columns) 


x=columns;
y=rows;

dist=ones(y,x);

j=0;
for k=1:x
  dist(:,k)=dist(:,k)+j;
  j=j+.5;
end


j=0;
for k=y:-1:1
  dist(k,:)=dist(k,:)+j;
  j=j+.5;
end
out=dist/sum(sum(dist));
