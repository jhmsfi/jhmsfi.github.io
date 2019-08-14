function[out]=plotstate(state) 

plotdata0=[];
plotdata1=[];
plotdata2=[];
j=0;

for rows=1:length(state(:,1))
  for columns=1:length(state(1,:))
    if state(rows,columns)==0
      j=j+1;
      plotdata0(j,:)=[columns length(state(:,1))-rows+1 state(rows,columns)];
    end
    if state(rows,columns)==1
      j=j+1;
      plotdata1(j,:)=[columns length(state(:,1))-rows+1 state(rows,columns)];
    end
    if state(rows,columns)==2
      j=j+1;
      plotdata2(j,:)=[columns length(state(:,1))-rows+1 state(rows,columns)];
    end
  end  
end

close all

hold on
figure(1);
set(gcf, 'Visible', 'off'); 


if sum(sum(plotdata1))>0
  scatter(plotdata1(:,1),plotdata1(:,2),plotdata1(:,3)*0+50,plotdata1(:,3))
end

if sum(sum(plotdata2))>0
  scatter(plotdata2(:,1),plotdata2(:,2),plotdata2(:,3)*0+100,plotdata2(:,3),'filled')
end

xlim([0 columns+1])
ylim([0 rows+1])


print(gcf, '-dpdf', ['figure',num2str(rand),'.pdf']); 
hold off
