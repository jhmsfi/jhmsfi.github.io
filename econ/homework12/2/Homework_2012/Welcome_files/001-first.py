###############################################################################
#
#                          MODEL FOR HOMEWORK 12

#              The Effect of Hierarchical Network Structure 
#                on Social Change and Diffusion Processes
#
#                   Omar A. Guerrero and Robert Mamada
#
#
#
# This simulation generates a layered network structure of agents at the level
# of individuals, regions, and countries. It perform a simple algorithm of 
# adoption of an attitute, copied from the neighbors. This model allows to 
# questions regarding the effect of topologies on diffussion processes at
# different scaling levels (3 for thi versions, but it should not be difficult
# to expand it for more levels).
#
# You need to have installed Python 2.5 of higher, and the  third-party 
# libraries Numpy and NetworkX
#
#
###############################################################################



import numpy as np
import networkx as nx
import random as rd



res = [] # vector that will store the proportion of revel agents of each experiment

for exp in range(1): # loop for number of experiments

    ## Parameters

    numOfCountries = 4

    pR = 0.1 # proportion of agents that get linked inter-regionally (it does not have an important effect)
    pC = 0.1 # proportion of agents that get linked inter-nationally (it does not have an important effect)
    
    # range for country sizes
    minCountrySize = 10
    maxCountrySize = 15
    
    # range for region sizes
    minRegionSize = 25
    maxRegionSize = 100

    # proportion of rebel agents at the start
    propOfMin = 0.05
    
    # type of network that can be chosen for each level (can be barabasi, erdos, small, lattice)
    netRegion = 'erdos'
    netCountry = 'erdos'
    netInter = 'lattice'
    
    # average degree of each network
    degRegion = 10
    degCountry = 4
    degWorld = 1


    ## Setup

    worldTemp = list() # list of countries
    world = list()
    for c in range(numOfCountries):
        worldTemp.append(list()) # add new empty country
        for i in range(rd.randint(minCountrySize, maxCountrySize)): # for each region
            size = rd.randint(minRegionSize, maxRegionSize)
            degree = rd.randint(minDegree, size/3)
            # generate network inside region
            if netRegion == 'erdos':
                GR = nx.watts_strogatz_graph(size, degRegion, 1)
            elif netRegion == 'lattice':
                GR = nx.watts_strogatz_graph(size, degRegion, 0)
            elif netRegion == 'barabasi':
                GR = nx.barabasi_albert_graph(size, degRegion)
            elif netRegion == 'small':
                GR = nx.watts_strogatz_graph(size, degRegion, .01)
            worldTemp[c].append(GR) # add new region graph to country c
        
        # generate the network for structure inside country
        if netRegion == 'erdos':
            GCtemp = nx.watts_strogatz_graph(len(worldTemp[c]), degCountry, 1)
        elif netRegion == 'lattice':
            GCtemp = nx.watts_strogatz_graph(len(worldTemp[c]), degCountry, 0)
        elif netRegion == 'barabasi':
            GCtemp = nx.barabasi_albert_graph(len(worldTemp[c]), degCountry)
        elif netRegion == 'small':
            GCtemp = nx.watts_strogatz_graph(len(worldTemp[c]), degCountry, 0.01)
        
        GC = nx.Graph()
        
        # the following lines just puts together the networks of the regions into a single network 
        uniqueID = 0
        for id, region in enumerate(worldTemp[c]):
            ids = dict()
            for node in region:
                GC.add_node(uniqueID, regionID=id)
                ids[node] = uniqueID
                uniqueID += 1
            for link in region.edges():
                GC.add_edge(ids[link[0]], ids[link[1]])
                
                
        for region in GCtemp:
            neighborRegions = GCtemp.neighbors(region)
            agentsInRegion = list()
            agentsInNeighbors = list()
            for node in GC:
                if GC.node[node]['regionID'] == region:
                    agentsInRegion.append(node)
                elif GC.node[node]['regionID'] in neighborRegions:
                    agentsInNeighbors.append(node)
            for node in agentsInRegion:
                if rd.random () < pR:
                    destination = rd.sample(agentsInNeighbors, 1)[0]
                    GC.add_edge(node, destination)
        world.append(GC)


    ## Graph of the world

    if netRegion == 'erdos':
        GItemp = nx.watts_strogatz_graph(numOfCountries, degWorld, 1)
    elif netRegion == 'lattice':
        GItemp = nx.watts_strogatz_graph(numOfCountries, degWorld, 0)
    elif netRegion == 'barabasi':
        GItemp = nx.barabasi_albert_graph(numOfCountries, degWorld)
    elif netRegion == 'small':
        GItemp = nx.watts_strogatz_graph(numOfCountries, degWorld, 0.01)
    GI = nx.Graph()

    uniqueID = 0
    for id, country in enumerate(world):
        ids = dict()
        for node in country:
            GI.add_node(uniqueID, countryID=id, regionID=country.node[node]['regionID'], affiliation='sq', tol = rd.random()/1.1)
            ids[node] = uniqueID
            uniqueID += 1
        for link in country.edges():
            GI.add_edge(ids[link[0]], ids[link[1]])
            
            
    for country in GItemp:
        neighborCountries = GItemp.neighbors(country)
        agentsInCountry = list()
        agentsInNeighbors = list()
        for node in GI:
            if GI.node[node]['countryID'] == country:
                agentsInCountry.append(node)
            elif GI.node[node]['countryID'] in neighborCountries:
                agentsInNeighbors.append(node)
        for node in agentsInCountry:
            if rd.random () < pC:
                destination = rd.sample(agentsInNeighbors, 1)[0]
                GI.add_edge(node, destination)


    ## Assign political affiliation

    # random affiliation
    for agent in GI:
        if rd.random() < propOfMin:
            GI.node[agent]['affiliation'] = 'rb'


    ## Simulation
    rec = []
    frb = int(GI.number_of_nodes()*propOfMin)
    for i in range(100): # loop for the steps of the simulation
        for agent in GI:
            neighbors = GI.neighbors(agent)
            rb = 0
            for neighbor in neighbors:
                if GI.node[neighbor]['affiliation'] == 'rb':
                    rb += 1
            if float(rb)/len(neighbors) > GI.node[agent]['tol']:
                GI.node[agent]['affiliation'] = 'rb'
                frb += 1
        
        rec.append(frb/float(GI.number_of_nodes()))
        

    ## Counts
    # get result of proportion of revel agents and store it in the vector res
    frb = 0
    for agent in GI:
        if GI.node[agent]['affiliation'] == 'rb':
            frb += 1
    
    res.append(frb/float(GI.number_of_nodes()))
    
    print 'Proportion of minority: ' + str(frb/float(GI.number_of_nodes()))
    print exp


# pring the mean and standard error of the result for all the experiments
print np.mean(res)
print np.std(res)/np.sqrt(len(res))