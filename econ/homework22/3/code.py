#################################### AT t=0 ####################################
#### [1] GENERATE THE LANDSCAPE ####
# Eggholder function
def f(x1,x2):
    from math import sqrt, fabs, sin
    a=sqrt(fabs(x2+x1/2+47))
    b=sqrt(fabs(x1-(x2+47)))
    c=-(x2+47)*sin(a)-x1*sin(b)
    return c

#### [2] CREATE CEO STRATEGY ####
local_boundedness = (50,50)

from random import randrange
ceo_start_point = randrange(-500,500), randrange(-500,500)#(144, -131)

"""
peak_outputs_in_range = []
for x1 in range(ceo_start_point[0]-local_boundedness[0], ceo_start_point[0]+local_boundedness[0]):
    for x2 in range(ceo_start_point[1]-local_boundedness[1], ceo_start_point[1]+local_boundedness[1]):
        peak_outputs_in_range.append((x1,x2,f(x1,x2)))
peak_outputs_in_range.sort(key=lambda x: -x[2])
ceo_goal = (peak_outputs_in_range[0][0],peak_outputs_in_range[0][1]) #(193, -146)
"""
def search_local_radius_for_maximal_peak_coordinates(start_point=(144, -131), local_boundedness=(50,50)):
    peak_outputs_in_range = []
    for x1 in range(start_point[0]-local_boundedness[0], start_point[0]+local_boundedness[0]):
        for x2 in range(start_point[1]-local_boundedness[1], start_point[1]+local_boundedness[1]):
            peak_outputs_in_range.append((x1,x2,f(x1,x2)))
    peak_outputs_in_range.sort(key=lambda x: -x[2])
    maximal_peak_coordinates = (peak_outputs_in_range[0][0],peak_outputs_in_range[0][1]) #(193, -146)
    return maximal_peak_coordinates
#################################### AT t>=1 ####################################

#### [3] MOVEMENT ON THE LANDSCAPE ####
time_steps = 100
movement_per_timestep = (1,1)

current_position = ceo_start_point

def movement_towards_goal(current_position, ceo_goal):
    if current_position[0]!=ceo_goal[0]:
        new_position_x1 = current_position[0]+movement_per_timestep[0] if (ceo_goal[0]>current_position[0]) else current_position[0]-movement_per_timestep[0]
    else:
        new_position_x1 = current_position[0]
    if current_position[1]!=ceo_goal[1]:
        new_position_x2 = current_position[1]+movement_per_timestep[1] if (ceo_goal[1]>current_position[1]) else current_position[1]-movement_per_timestep[1]
    else:
        new_position_x2 = current_position[1]
    current_position = (new_position_x1, new_position_x2)
    return current_position

for i in range(20):
    current_position = movement_towards_goal(current_position, ceo_goal)
    print(current_position)

#### [4] "THINGS GOING WRONG" ####
probability_things_go_wrong = 0.1
does_expert_report = 1#1 or 0
#does_expert_report = 0

def local_deviation(current_position, movement_per_timestep=(1,1)):
    import random
    new_position_x1 = current_position[0] + random.choice([-1,1])*movement_per_timestep[0]
    new_position_x2 = current_position[1] + random.choice([-1,1])*movement_per_timestep[1]
    current_position = (new_position_x1, new_position_x2)
    return current_position




# if "deviation" --> new peak (>= ceo_goal) within their search radius, follow path
# otherwise, report


#################################### RUN ####################################
def generate_start_criteria():
    #### Separate this function because want to run iteration for same starting criteria both with and without reporting --> goal updating ####
    #### Generate random starting point ####
    from random import randrange
    ceo_start_point = randrange(-500,500), randrange(-500,500)
    #### Create goal from boundedly rational search ####
    ceo_goal = search_local_radius_for_maximal_peak_coordinates(ceo_start_point, local_boundedness)
    old_goal = ceo_goal
    current_position = ceo_start_point
    return ceo_start_point, ceo_goal, old_goal, current_position

def run_single_iteration(ceo_start_point, ceo_goal, old_goal, current_position, does_expert_report=1):
    #### Iterate through time_steps ####
    timestep_at_which_reaches_goal = 0
    import numpy as np
    time_steps = 100
    timestep_at_which_reaches_goal = 'N/A'
    for time_step in range(time_steps):
        #print(current_position)
        # Do things go wrong?
        things_went_wrong = np.random.choice(np.arange(0,2), p=[1-probability_things_go_wrong, probability_things_go_wrong])
        # Business as usual
        if things_went_wrong==0:
            current_position = movement_towards_goal(current_position, ceo_goal)
        # Things go wrong
        else:
            current_position = local_deviation(current_position, movement_per_timestep)
            maximal_peak_coordinates = search_local_radius_for_maximal_peak_coordinates(current_position, local_boundedness)
            # Did they find a new optimal peak > CEO peak, follow new path (temporarily renameing ceo_goal --> follow that path)
            if (maximal_peak_coordinates!=ceo_goal) and f(maximal_peak_coordinates[0],maximal_peak_coordinates[1])>f(ceo_goal[0],ceo_goal[1]) and (does_expert_report==0):
                ceo_goal = maximal_peak_coordinates
        if (current_position==ceo_goal) and (timestep_at_which_reaches_goal=='N/A'):
            timestep_at_which_reaches_goal = time_step
    #### Return original vs. actualized fitness and timestep_at_which_reaches_goal ####
    original_fitness = f(old_goal[0], old_goal[1])
    actualized_fitness = f(current_position[0], current_position[1])
    return original_fitness, actualized_fitness, timestep_at_which_reaches_goal

def welfare_analysis():
    with_reporting_error, without_reporting_error = [], []
    for i in range(1000):
        print(i)
        ceo_start_point, ceo_goal, old_goal, current_position = generate_start_criteria()
        with_reporting_error.append(run_single_iteration(ceo_start_point, ceo_goal, old_goal, current_position, does_expert_report=1))
        without_reporting_error.append(run_single_iteration(ceo_start_point, ceo_goal, old_goal, current_position, does_expert_report=0))
    return with_reporting_error, without_reporting_error

# new goal vs. original goal (frequency difference [not reporting things go wrong path only])
# fitness [compared to not reporting things going wrong]
# differnet types of landscapes --> effects
# search path [tomorrow]
# ostensbily count steps ~= some measure of things going wrong being bad (which is why might want to correct)

#### Actualized fitness statistics ####
## [1] Frequency of attaining CEO peak ##
len([i for i in with_reporting_error if i[0]==i[1]])/len(with_reporting_error)#0.894 (89% of the time make it to CEO goal peak when reporting error), 0.91
len([i for i in without_reporting_error if i[0]==i[1]])/len(without_reporting_error)#0.214 (21% of the time make it to CEO goal peak when not reporting error), 0.25

## [2] Fitness ##
from statistics import mean, stdev
mean([i[1] for i in with_reporting_error]), stdev([i[1] for i in with_reporting_error])# (427.5179310585267, 190.88710945960992), (450.00580457712664, 184.23592892159377)
## Not reporting error ##
mean([i[1] for i in without_reporting_error]), stdev([i[1] for i in without_reporting_error])# (488.64486822049844, 214.2272587414585), (559.2841036207079, 208.57971870203022)

## [3] Timesteps until reaching peak ##
time_steps = 500#100
mean([i[2] if (i[2]!='N/A') else time_steps for i in with_reporting_error]), stdev([i[2] if (i[2]!='N/A') else time_steps for i in with_reporting_error])#(48.816, 11.887449493287257), (50.67, 8.826103387684794)
mean([i[2] if (i[2]!='N/A') else time_steps for i in without_reporting_error]), stdev([i[2] if (i[2]!='N/A') else time_steps for i in without_reporting_error])#(72.551, 26.920328807484932), (75.88, 34.313551229504036)




#### ALL TIMESTEPS FOR GRAPH ####

def run_single_iteration_all_timesteps(ceo_start_point, ceo_goal, old_goal, current_position, does_expert_report=1):
    #### Iterate through time_steps ####
    timestep_at_which_reaches_goal = 0
    import numpy as np
    time_steps = 500
    timestep_at_which_reaches_goal = 'N/A'
    fitness_journey = []
    for time_step in range(time_steps):
        #print(current_position)
        # Do things go wrong?
        things_went_wrong = np.random.choice(np.arange(0,2), p=[1-probability_things_go_wrong, probability_things_go_wrong])
        # Business as usual
        if things_went_wrong==0:
            current_position = movement_towards_goal(current_position, ceo_goal)
        # Things go wrong
        else:
            current_position = local_deviation(current_position, movement_per_timestep)
            maximal_peak_coordinates = search_local_radius_for_maximal_peak_coordinates(current_position, local_boundedness)
            # Did they find a new optimal peak > CEO peak, follow new path (temporarily renameing ceo_goal --> follow that path)
            if (maximal_peak_coordinates!=ceo_goal) and f(maximal_peak_coordinates[0],maximal_peak_coordinates[1])>f(ceo_goal[0],ceo_goal[1]) and (does_expert_report==0):
                ceo_goal = maximal_peak_coordinates
        if (current_position==ceo_goal) and (timestep_at_which_reaches_goal=='N/A'):
            timestep_at_which_reaches_goal = time_step
        #### Collect interim info for graph ####
        actualized_fitness = f(current_position[0], current_position[1])
        fitness_journey.append(actualized_fitness)
    original_fitness = f(old_goal[0], old_goal[1])
    actualized_fitness = f(current_position[0], current_position[1])
    #### Return original vs. actualized fitness and timestep_at_which_reaches_goal ####
    return original_fitness, actualized_fitness, timestep_at_which_reaches_goal, fitness_journey

def welfare_analysis_all_timesteps():
    with_reporting_error, without_reporting_error = [], []
    for i in range(100):
        print(i)
        ceo_start_point, ceo_goal, old_goal, current_position = generate_start_criteria()
        with_reporting_error.append(run_single_iteration_all_timesteps(ceo_start_point, ceo_goal, old_goal, current_position, does_expert_report=1))
        without_reporting_error.append(run_single_iteration_all_timesteps(ceo_start_point, ceo_goal, old_goal, current_position, does_expert_report=0))
    return with_reporting_error, without_reporting_error

import matplotlib
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
x = list(range(1,time_steps+1))
for i in with_reporting_error:
    y = i[3]
    plt.plot(x, y, color="black", linewidth=0.5, label='With reporting error')
for i in without_reporting_error:
    y = i[3]
    plt.plot(x, y, color="blue", linewidth=0.5, label='Without reporting error')
#plt.title('Fitness over time')
plt.title('Fitness over time 500 time steps - single peaked landscape')
black_patch = mpatches.Patch(color='black', label='With reporting error')
blue_patch = mpatches.Patch(color='blue', label='Without reporting error')
plt.legend(handles=[black_patch, blue_patch])
plt.xlabel('Time step')
plt.ylabel('Fitness')
plt.show()
#plt.savefig('Fitness over time 500 time steps')
plt.savefig('Fitness over time 500 time steps - single peaked landscape')
plt.close()

#### Talked about phenomena, what makes us excited --> landed on counter ####
#### Did something neither of us had done, borrowed from different literatures ####
#### More formal political economy, NK landscapes from Management, which itself was built on models taken from evolutionary biology ####

#################################### SIMPLE LANDSCAPE - WANT TO SHOW THAT LANDSCAPE MATTERS! EXPLORATION MAY NOT BE VALUABLE ####################################
# https://www.sfu.ca/~ssurjano/optimization.html
# with_reporting_error_original_function, without_reporting_error_original_function = with_reporting_error, without_reporting_error
def f(x1,x2):
    return 100 - (x1**2 + x2**2)

def generate_start_criteria():
    #### Separate this function because want to run iteration for same starting criteria both with and without reporting --> goal updating ####
    #### Generate random starting point ####
    from random import randrange
    ceo_start_point = randrange(-40,40), randrange(-40,40)
    #### Create goal from boundedly rational search ####
    ceo_goal = search_local_radius_for_maximal_peak_coordinates(ceo_start_point, local_boundedness)
    old_goal = ceo_goal
    current_position = ceo_start_point
    return ceo_start_point, ceo_goal, old_goal, current_position


with_reporting_error, without_reporting_error = welfare_analysis_all_timesteps()
#### Actualized fitness statistics ####
## [1] Frequency of attaining CEO peak ##
len([i for i in with_reporting_error if i[0]==i[1]])/len(with_reporting_error)#0.89
len([i for i in without_reporting_error if i[0]==i[1]])/len(without_reporting_error)#0.83

## [2] Fitness ##
from statistics import mean, stdev
mean([i[1] for i in with_reporting_error]), stdev([i[1] for i in with_reporting_error])#(99.72, 0.8537498983243799)
## Not reporting error ##
mean([i[1] for i in without_reporting_error]), stdev([i[1] for i in without_reporting_error])#(99.65, 0.8087276451565162)

## [3] Timesteps until reaching peak ##
time_steps = 500#100
mean([i[2] if (i[2]!='N/A') else time_steps for i in with_reporting_error]), stdev([i[2] if (i[2]!='N/A') else time_steps for i in with_reporting_error])#(30.67, 9.878100459444047)
mean([i[2] if (i[2]!='N/A') else time_steps for i in without_reporting_error]), stdev([i[2] if (i[2]!='N/A') else time_steps for i in without_reporting_error])#(30.52, 9.16016849564935)


#################################### PLOT SINGLE IMAGE OF 3D LANDSCAPE ####################################
# https://jakevdp.github.io/PythonDataScienceHandbook/04.12-three-dimensional-plotting.html
x = np.linspace(-500, 500, 501)
y = np.linspace(-500, 500, 501)

def f(x1,x2):
    from math import sqrt, fabs, sin
    a=np.sqrt(np.fabs(x2+x1/2+47))
    b=np.sqrt(np.fabs(x1-(x2+47)))
    c=-(x2+47)*np.sin(a)-x1*np.sin(b)
    return np.float64(c)

X, Y = np.meshgrid(x, y)
Z = f(X, Y)
fig = plt.figure()
ax = plt.axes(projection='3d')
ax.contour3D(X, Y, Z, 50, cmap='binary')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_zlabel('z');
fig.show()
fig.savefig('Cone')
plt.close()

def f(x1,x2):
    return 100 - (x1**2 + x2**2)

X, Y = np.meshgrid(x, y)
Z = f(X, Y)

ax.plot(x[250], y[250], f(x[250],y[250]), 'g*')
ax.plot(0,0,105, 'g*')
