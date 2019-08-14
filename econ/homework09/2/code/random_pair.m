
function [pair_vector] = random_pair(vector_size)

picked_vector=zeros(1,vector_size); %Tracks which pairing are already taken
pair_vector=zeros(1,vector_size); %Tracks who is paired with who

for x=1:vector_size

    if picked_vector(x)==0

        while picked_vector(x)==0
            
            picked=ceil(rand*vector_size);
        
        
            if picked_vector(picked)==0 && x~=picked
                picked_vector(x)=1;
                picked_vector(picked)=1;            
                pair_vector(picked)=x;
                pair_vector(x)=picked;

            end
        end
    end
end

