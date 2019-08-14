

%Random pairings
%Look at one other
%Adopt ponzi scheme
%Always withdraw interest

%No cap
%Cap = 0.5
%Cap = .25
%Cap = .1

clc
clear

number_agents=1000; %Only even numbers of agents
initial_investors=10;
investment=1;
payout_percent=0.1;
initial_ponzi_balance=0;
time_steps=100;
disivestment_rate=0;
number_of_pairings=10;


for x=1:4
    
    if x==1
        growth_rate_limit=1;
    elseif x==2
        growth_rate_limit=0.5;
    elseif x==3
        growth_rate_limit=0.15;
    else
        growth_rate_limit=0.1;
    end
    
    
    population=zeros(1,number_agents);
    population(1,1:initial_investors)=ones(1,initial_investors);


    ponzi_balance=initial_ponzi_balance;
    new_investors=sum(population);
    
    t=1;
    
    ponzi_balance_tracker=zeros(1,time_steps);
    investors_tracker=zeros(1,time_steps);
    new_investors_tracker=zeros(1,time_steps);
    payout_rate_tracker=zeros(1,time_steps);
 

    while t < time_steps && ponzi_balance >= 0
    
    
        %ponzi dynamics
    
        ponzi_balance=ponzi_balance+investment*new_investors;
    
        ponzi_balance=ponzi_balance-sum(population)*investment*payout_percent;
    
        pairings=random_pair(number_agents);
    
        new_population=population;
        
        for b=1:number_agents
            if population(1,b)==1
                if rand < disivestment_rate
                    new_population(1,b)=0;
                    ponzi_balannce=ponzi_balance-investment;
                end
            end
        end   
        
        investor_cap=floor((1+growth_rate_limit)*sum(population));
    
        for c=1:number_of_pairings
            pairings=random_pair(number_agents);
            for a=1:number_agents    
                if sum(new_population) < investor_cap
                    if population(1,a)~=1
                        if population(1,pairings(1,a))==1
                            new_population(1,a)=1;             
                        end
                    end
                end
            end
        end
            
   
        %end learning rule
    
        %learning/new investment
        new_investors=sum(new_population)-sum(population);
    
        population=new_population;
    
        ponzi_balance_tracker(t)=ponzi_balance;
        investors_tracker(t)=sum(population);
        new_investors_tracker(t)=new_investors;
        %diffusion - new investors
    

        payout_rate_tracker(t)=sum(population)*investment*payout_percent/ponzi_balance;

        t=t+1;

    
    end

    diffusion_tracker=(investment*new_investors_tracker)./ponzi_balance_tracker;


    subplot(2,1,1)

    if x==1
        plot(investors_tracker,'k')
    elseif x==2
        plot(investors_tracker,'b')
    elseif x==3
        plot(investors_tracker,'g')
    else
        plot(investors_tracker,'c')
    end
        
    axis([0 50 0 number_agents*1.1])

    xlabel('Time')
    ylabel('Investors')

    hold on
    
    subplot(2,1,2)

    if x==1
        plot(ponzi_balance_tracker,'k:')
    elseif x==2
        plot(ponzi_balance_tracker,'b')
    elseif x==3
        plot(ponzi_balance_tracker,'g')
    else
        plot(ponzi_balance_tracker,'c')
    end
    
    plot(ponzi_balance_tracker)
    axis([0 50 0 900])

    xlabel('Time')
    ylabel('Balance')
    
    hold on
    
    pause

    
end

    
subplot(2,1,1)
hold off
subplot(2,1,2)
hold off