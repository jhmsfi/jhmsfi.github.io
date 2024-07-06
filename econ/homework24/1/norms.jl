using Plots


function simulate(;
    birthRate = 1,
    ageRate = 1,
    yearOfDeath = 100,
    β = (aS, aI) -> 0.001,
    ϵ = 0.01,
    dt = 1,
    numBuckets = 100,
    years = 100,
    plotSurface = false,
    heatMap = true,
)
    numSteps = (Int64(years / dt))
    
    
    S = zeros(Float64, (numSteps, numBuckets))
    I = zeros(Float64, (numSteps, numBuckets))
    
    S[1, :] .+= (1 .- ϵ)
    I[1, :] .+= ϵ
    
    for t in 1:numSteps-1
    
        
        # Count up infections
        infections = zeros(Float64, numBuckets)
        for aS in 1:numBuckets
            for aI in 1:numBuckets
                infections[aS] += dt * β(aS, aI) * S[t, aS] * I[t, aI]
            end
        end
        # Avoid negative infections.
        # This generally shouldn't be possible, but it is
        # with a choppy enough differential equation simulation; and it becomes
        # possible with a negative beta – as in the negative parental influence.
        infections = max.(infections, 0.0)
    
    
        # Apply infections
    
        S[t, :] .-= infections
        I[t, :] .+= infections
        
        
        S[t+1, 1] = birthRate
        # Age the population
        for a in 2:numBuckets
            # You could do this way faster with a ring
            # buffer but let's not worry about that.
            S[t+1, a] = S[t, a - 1] * ageRate * dt + (1 - (ageRate * dt)) * S[t, a]
            I[t+1, a] = I[t, a - 1] * ageRate * dt + (1 - (ageRate * dt)) * I[t, a]
        end
    
    end
    if plotSurface
        plotlyjs()
        plt = surface(I, xlabel="age", ylabel="years", zlabel="number infected")
        display(plt)
    elseif heatMap
        heatmap(I, xlabel="age", ylabel="years", zlabel="number infected")
    else
        return I
    end

end

teenagerCohort = zeros(Float64, 100)
teenagerCohort[14:17] .= 1

