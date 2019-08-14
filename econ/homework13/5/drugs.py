import networkx as nx
import random
import math
import numpy
import matplotlib.pyplot as plt
from numpy import cumsum
from numpy.random import rand

def weighted_choice(weights, objects):
    """Return a random item from objects, with the weighting defined by weights 
    (which must sum to 1)."""
    cs = cumsum(weights) #An array of the weights, cumulatively summed.
    idx = sum(cs < rand()) #Find the index of the first weight over a random value.
    return objects[idx]

def random_subset(seq, m):
    """ Return m unique elements from seq.

    This differs from random.sample which can return repeated
    elements if seq holds repeated elements.
    """
    targets = set()
    while len(targets) < m:
        x = random.choice(seq)
        targets.add(x)
    return targets

def v(v):
    if v > 2:
        return 'high'
    return 'low'


def draw(mu,s,n):
    draws = []
    for i in range(0,n):
      draws.append(random.gauss(mu,s))
    return draws  

def success(mu,s,l):    
    draws = draw(mu,s,l)
    return sum(draws)

def process(P,N,D,W,L,M,V,R):
    G = nx.erdos_renyi_graph(N, P, directed=True) # ? what connectedness
    G.graph['drug'] = {}
    G.graph['strats'] = {}
    G.graph['strats']['low_mean']=[]
    G.graph['strats']['high_mean']=[]
    G.graph['strats']['low_loperc']=[]
    G.graph['strats']['low_hiperc']=[]
    G.graph['strats']['high_loperc']=[]
    G.graph['strats']['high_hiperc']=[]
    G.graph['reputation']={}
    G.graph['reputation']['mean']=[]
    G.graph['reputation']['loperc']=[]
    G.graph['reputation']['hiperc']=[]
    G.graph['reputation']['dist']={}
    G.graph['out_degrees']=[]
    #initialize
    for node in G.nodes():    
        G.node[node]['low'] = random.randint(1,W)
        G.node[node]['high'] = random.randint(1,W)
        G.node[node]['success'] = 0.0  

    G.graph['data'] = {}
    for node in G.nodes():
        G.graph['data'][node] = {}
        G.graph['data'][node]['reputation']=[]
        G.graph['data'][node]['low']=[]
        G.graph['data'][node]['high']=[]

    for i in range(0,D):
        var = random.randint(1,V)
        d = {'mean':random.randint(0,M), 'variance':var, 'mvar':v(var)}  

        for node in G.nodes():
            G.graph['data'][node]['reputation'].append(G.in_degree(node))
            G.graph['data'][node]['low'].append(G.node[node]['low'])
            G.graph['data'][node]['high'].append(G.node[node]['high'])
        G.graph['strats']['low_mean'].append(numpy.mean([G.graph['data'][node]['low'][i] for node in G.nodes()]))
        G.graph['strats']['high_mean'].append(numpy.mean([G.graph['data'][node]['high'][i] for node in G.nodes()]))
        G.graph['strats']['low_loperc'].append(numpy.percentile([G.graph['data'][node]['low'][i] for node in G.nodes()],25))
        G.graph['strats']['low_hiperc'].append(numpy.percentile([G.graph['data'][node]['low'][i] for node in G.nodes()],75))
        G.graph['strats']['high_loperc'].append(numpy.percentile([G.graph['data'][node]['high'][i] for node in G.nodes()],25))
        G.graph['strats']['high_hiperc'].append(numpy.percentile([G.graph['data'][node]['high'][i] for node in G.nodes()],75))
        G.graph['reputation']['mean'].append(numpy.mean([G.graph['data'][node]['reputation'][i] for node in G.nodes()]))
        G.graph['reputation']['loperc'].append(numpy.percentile([G.graph['data'][node]['reputation'][i] for node in G.nodes()],25))
        G.graph['reputation']['hiperc'].append(numpy.percentile([G.graph['data'][node]['reputation'][i] for node in G.nodes()],75))
        G.graph['reputation']['dist'][i]=[G.graph['data'][node]['reputation'][i] for node in G.nodes()]
        G.graph['out_degrees'].append(numpy.mean([G.out_degree(node) for node in G.nodes()]))


        for t in range(0,W):
            for node in G.nodes():
                strategy = G.node[node][d['mvar']]

                if strategy > t:
                  G.node[node]['success'] += success(d['mean'],d['variance'],L)
                else:
                    mu_hat=0
                    adopted=[neigh for neigh in G.neighbors(node) if G.node[neigh][d['mvar']]>t]
                    for neigh in adopted:
                        mu_hat+=G.node[node]['success']
                    for neigh in adopted:
                        if mu_hat<0:
                            if numpy.random.binomial(1,R):
                                G.remove_edge(node,neigh)

        # find most successfull dudes in neighbor's neighborhood, and complement the 2-neighborhood with random picks if the 2-neighborhood is too small                   

        for node in G.nodes():
            G.node[node]['success'] = 0.0 #reset success for later rounds
            npick = max(0,int(N*P)-len(G.successors(node))) # successors of node are those that the node observes (sends reputation signal to)
            nn = [G.successors(neigh) for neigh in G.successors(node)]
            nn = [n for nlist in nn for n in nlist]

            while len(nn)<npick:
                pick=random.choice(G.nodes())
                while pick in nn:
                    pick=random.choice(G.nodes())
                nn.append(pick)

            l = []
            for n in nn:
                wt = 1 + float(1/G.node[n][d['mvar']])*d['mean'] # (had to add one) possibly subtract minimum strategy to normalize first mover advantage
                #flrwt = math.floor(wt)
                #list.extend([n] * int(flrwt))
                l.append(wt)
            l=list(numpy.array(l)/float(sum(l)))

            for _ in range(0,npick):
                choice = weighted_choice(l,nn)
                G.add_edge(node,choice)

    #        choices = random_subset(list,npick)
    #        for choice in choices:
    #            G.add_edge(node,choice)

        # updating the strategy
        if i > 0:
            for node in G.nodes():

                delta = G.graph['data'][node]['reputation'][i]-G.graph['data'][node]['reputation'][i-1]
                ndelta = -999999999

                for neigh in G.successors(node):
                    tmp = G.graph['data'][neigh]['reputation'][i]-G.graph['data'][neigh]['reputation'][i-1]
                    if tmp > ndelta: # watch for heuristic pick
                        strat = G.node[neigh][d['mvar']]
                        ndelta = tmp 

                if ndelta > delta:
                    if strat > G.node[node][d['mvar']]:
                        G.node[node][d['mvar']] += 0.1
                    elif strat < G.node[node][d['mvar']]:
                        if G.node[node][d['mvar']] > 1:
                            G.node[node][d['mvar']] -= 0.1 
                    #else no change


#                    G.node[node][d['mvar']] = math.ceil(float(G.node[node][d['mvar']] + strat)/2)           #old avging
    return G

           
              
P = 0.2 # original ER graph density
N = 100
D = 150 # number of drugs
W = 5 # time to wait
L = 5 # number of patients
M = 1 # mean satisfaction
V = 5 # variance
R = 0.5 # chance of dropping a tie (decay)      

G=process(P,N,D,W,L,M,V,R)
nx.write_gpickle(G,'graph.gpickle')       