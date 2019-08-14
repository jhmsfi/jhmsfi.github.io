
%Like Ponzi2, but with more pairings a time step
%Like Ponzi3, but with connectivity matrix
%Like Ponzi4, but with all-or-nothing investing rules & compound interest;

clc
clear

number_agents=1000; %Only even numbers of agents
initial_investors=10;
investment=1;
interest_rate=0.1;
initial_ponzi_balance=0;
time_steps=100;
disivestment_rate=.1;
growth_rate_limit=.2;





for x=1:4
    
    new_population=zeros(1,number_agents);
    new_population(1,1:initial_investors)=ones(1,initial_investors);
    average_connectivity=4;
    
    
    if x==1
        growth_rate_limit=1;
    elseif x==2
        growth_rate_limit=0.5;
    elseif x==3
        growth_rate_limit=0.15;
    else
        growth_rate_limit=0.1;
    end

    connectivity_matrix=zeros(number_agents);

    for d=1:number_agents
        for e=1:number_agents
            if rand < average_connectivity/number_agents
                connectivity_matrix(d,e)=1;
            end
        end
    end

    %average_connectvity/number_agents

    ponzi_balance=initial_ponzi_balance;

    new_investors=sum(new_population);

    t=1;

    ponzi_balance_tracker=zeros(1,time_steps);
    investors_tracker=zeros(1,time_steps);
    new_investors_tracker=zeros(1,time_steps);
    payout_rate_tracker=zeros(1,time_steps);

    agent_ponzi_balances=new_population*investment;

    while t < time_steps && ponzi_balance >= 0
    
        t;

        population=new_population;
    
        disinvestment_this_turn=0;
    
        agent_ponzi_balances=agent_ponzi_balances*(1+interest_rate);
    
        %ponzi dynamics
    
        ponzi_balance=ponzi_balance+investment*new_investors;
        
        
        for b=1:number_agents
            if population(1,b)==1
                if rand < disivestment_rate
                    new_population(1,b)=0;
                    ponzi_balance=ponzi_balance-agent_ponzi_balances(1,b);
                    disinvestment_this_turn=disinvestment_this_turn+agent_ponzi_balances(1,b);
                end
            end
        end
        
        investor_cap=floor((1+growth_rate_limit)*sum(population));
     
    
        for c=1:number_agents
            if sum(new_population) < investor_cap
                if population(1,c)~=1
                    if sum(connectivity_matrix(c,:).*population) > 0
                        new_population(1,c)=1;
                        agent_ponzi_balances(1,c)=investment;
                    end
               end
            end
        end    
       
      

     
        %end learning rule
    
        %learning/new investment
        new_investors=sum(new_population)-sum(population);
    
    
    
        ponzi_balance_tracker(t)=ponzi_balance;
        investors_tracker(t)=sum(population);
        new_investors_tracker(t)=new_investors;
        %diffusion - new investors
    

        payout_rate_tracker(t)=disinvestment_this_turn/ponzi_balance;

        t=t+1;

        %pause
    
        ponzi_balance;
    
    
    end




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
