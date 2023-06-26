import numpy as np
import scipy as sp
import networkx as nx
from sklearn.datasets import make_spd_matrix
from copy import deepcopy
from collections import defaultdict
from matplotlib import pyplot as plt 

plt.rcParams.update({'font.size': 16})
plt.rcParams["figure.figsize"] = (8,6)
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['axes.facecolor'] = 'w'
plt.rcParams["figure.titleweight"] = 'bold'
plt.rc('font', family='Helvetica')



class Model:
    def __init__(self,N,M,num_attributes,P,Wp,steps,peer_effect,which_network,who_influences):
        self.N = N
        self.M = M
        self.NAttr = num_attributes
        self.P = P
        self.Wp = Wp
        self.steps = steps
        self.which_network = which_network
        self.who_influences = who_influences
        self.results = defaultdict(dict)
        self.peer_effect = peer_effect
        self.initNetwork()
        self.initAttributes()
        self.chooseRepresentative()
        self.runSimulation()
        return

    def initNetwork(self):
        if self.which_network == 'holme-kim':
            self.G = nx.powerlaw_cluster_graph(n=self.N,m=self.M,p=self.P)
        elif self.which_network == 'newman-watts-strogatz':
            self.G = nx.newman_watts_strogatz_graph(self.N,self.M,self.Wp)
        elif self.which_network == 'barabasi-albert':
            self.G = nx.barabasi_albert_graph(n=self.N,m=self.M)

        self.clustering_coefs = nx.clustering(self.G)
        self.eigenvector_centralities = nx.eigenvector_centrality(self.G)
        return
    
    def initAttributes(self):
        for attribute in range(self.NAttr):
            S = make_spd_matrix(n_dim=self.NAttr)
            self.attributes = np.random.multivariate_normal(mean=(np.random.randint(low=1,high=10,size=self.NAttr)), cov=S, size=(self.N))

            #self.attributes = np.random.multinomial(self.NAttr, [1/self.NAttr]*self.NAttr, size=self.N)

            attribute_dict = {node : self.attributes[node] for node in list(self.G.nodes())}
            nx.set_node_attributes(self.G,attribute_dict,"attr")
            
            #self.multinomial_entropy = (self.NAttr - 1)/2 * np.log2(2*np.pi * self.N * np.e) + 0.5*np.sum(self.NAttr*np.log2(1/self.NAttr))
        return
    
    def chooseRepresentative(self):
        expectation = np.mean(self.attributes, axis=0)
        self.representative = np.argmin([sp.spatial.distance.euclidean(expectation, self.attributes[node]) for node in range(self.N)])
        self.highest_status = np.argmax(list(self.eigenvector_centralities.values()))
        d = dict.fromkeys(list(self.G.nodes()),0)
        d.update({self.representative : 1 })
        nx.set_node_attributes(self.G, d, "is_representative")

        self.biggest_outlier = np.argmax([sp.spatial.distance.euclidean(expectation, self.attributes[node]) for node in range(self.N)])

        return

    def runSimulation(self):
        for step in range(self.steps):
            # update attribute of each node as a function of their neighbors.              
            self.results[step]['G'] = deepcopy(self.G)
            for i in self.G.nodes():
                ego_attr = self.G.nodes[i]['attr']

                if self.who_influences == 'higher status peers':
                #mean_peer_attr = np.mean([self.G.nodes[j]['attr'] for j in self.G.neighbors(i)])
                    peer_attr = [self.G.nodes[j]['attr'] for j in self.G.neighbors(i) if self.eigenvector_centralities[j] >= self.eigenvector_centralities[i]]

                    if len(peer_attr) > 0:
                        mean_peer_attr = np.mean(peer_attr)
                # only of higher status people
                    else:
                        mean_peer_attr = ego_attr
                elif self.who_influences == 'all peers':
                    mean_peer_attr = np.mean([self.G.nodes[j]['attr'] for j in self.G.neighbors(i)])



                self.G.nodes[i]['attr'] = ego_attr * (1- self.peer_effect) + mean_peer_attr * self.peer_effect

            expectation = np.mean(np.array([i for i in nx.get_node_attributes(self.G,'attr').values()]), axis=0)
            representativity = sp.spatial.distance.euclidean(expectation, self.attributes[self.representative])
            self.results[step]['representativity'] = representativity

            least_represented = sp.spatial.distance.euclidean(self.attributes[self.biggest_outlier], self.attributes[self.representative])
            self.results[step]['least_represented'] = least_represented

            high_status_representativity = sp.spatial.distance.euclidean(expectation, self.attributes[self.highest_status])
            self.results[step]['high_status_representativity'] = high_status_representativity
        return


def runExperiment(N,M,num_attributes,P,Wp,steps,peer_effect,number_of_runs,who_influences):
    
    results = defaultdict(dict)

    for network in ['holme-kim','barabasi-albert','newman-watts-strogatz']:
    
        yr = [0]*steps
        yhsr = [0]*steps
        ylr = [0]*steps
    

        for run in range(number_of_runs):
            model = Model(N=N,M=M,num_attributes=num_attributes,P=P,Wp=Wp,steps=steps,peer_effect=peer_effect,which_network=network,who_influences=who_influences)
            x = list(model.results.keys())
            yr = [sum(v) for v in zip([model.results[i]['representativity'] for i in x],yr)]
            yhsr = [sum(v) for v in zip([model.results[i]['high_status_representativity'] for i in x], yhsr)]
            ylr = [sum(v) for v in zip([model.results[i]['least_represented'] for i in x], ylr)]
        
        
        results[network]['x'] = x
        results[network]['yr'] = np.array(yr)/number_of_runs
        results[network]['yhrs'] = np.array(yhsr)/number_of_runs
        results[network]['ylr'] = np.array(ylr )/ number_of_runs


    return results


def visualizeExperiment(results):
    ms = 6
    lw = 2
    
    x = results['holme-kim']['x']
    y_hk1 = results['holme-kim']['yr']
    y_hk2 = results['holme-kim']['yhrs']

    y_ba1 = results['barabasi-albert']['yr']
    y_ba2 = results['barabasi-albert']['yhrs']

    y_nws1 = results['newman-watts-strogatz']['yr']
    y_nws2 = results['newman-watts-strogatz']['yhrs']



    plt.plot(x,y_hk1,linestyle='solid',marker='o', color='0.125',label='Most Representative - Holme-Kim',linewidth=lw,markersize=ms)
    plt.plot(x,y_hk2,linestyle='dotted',marker='o', color='0.125',label='Highest Status - Holme-Kim',linewidth=lw,markersize=ms)

    plt.plot(x,y_ba1,linestyle='solid',marker='d', color='#0071A4',label='Most Representative - Newman-Watts',linewidth=lw,markersize=ms)
    plt.plot(x,y_ba2,linestyle='dotted',marker='d', color='#0071A4',label='Highest Status - Newman-Watts',linewidth=lw,markersize=ms)

    plt.plot(x,y_nws1,linestyle='solid',marker='v', color='#FF3366',label='Most Representative - Barabasi-Albert',linewidth=lw,markersize=ms)
    plt.plot(x,y_nws2,linestyle='dotted',marker='v', color='#FF3366',label='Highest Status - Barabasi-Albert',linewidth=lw,markersize=ms)


#plt.plot(x4,y4,linestyle='solid',marker='o', color='0.425',label='M4',linewidth=4,markersize=4)
#plt.plot(x3,y3,linestyle='solid',marker='o', color='green',label='M3',linewidth=4,markersize=4)

    plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))
    #plt.legend()
    plt.title('Change in Representativity')
    plt.xlabel('Step')
    plt.ylabel('Representativity')
    return