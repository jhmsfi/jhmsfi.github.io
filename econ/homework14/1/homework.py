__author__ = 'christophaymanns'
import numpy as np
import scipy as sc
import networkx as nx
import matplotlib.pylab as pl
import pdb
import os
import pickle

class Spin_doctor_model():

    def __init__(self, exp_type = 'initial'):

        self.exp_type = exp_type
        self.data = {}
        self.params = {}
        self.fig_save_path = os.getcwd() + '/figs/'
        if not os.path.exists(self.fig_save_path):
            os.makedirs(self.fig_save_path)

    def do_exp(self):

        if self.exp_type == 'initial':

            self.initial_cons(n_seeds=10)
            self.save_self()

            f = pl.figure()
            pl.plot(self.data['pi'],self.data['xms'],'o-')
            pl.title('Average belief vs initial spread prob.')
            pl.xlabel('in. spread prob')
            pl.ylabel('Av. belief')
            f.savefig(self.fig_save_path+self.exp_type+'.png',format ='png')

        elif self.exp_type == 'pic':
            self.pic()
            self.save_self()

            f = pl.figure()
            pl.plot(self.data['q'],self.data['pic'],'o-')
            pl.title('Comm. prob  vs. critica in. spreak prob')
            pl.ylabel('in. spread prob')
            pl.xlabel('comm. prob')
            f.savefig(self.fig_save_path+self.exp_type+'.png',format ='png')

        elif self.exp_type == 'influ_ER':
            self.influencer(nw_type='ER')
            self.save_self()

            f = pl.figure()
            pl.plot(self.data['bmult'],self.data['xms'],'o-')
            pl.title('Effect of targeted promotion - ER')
            pl.ylabel('Average belief')
            pl.xlabel('Spending multiplier')
            f.savefig(self.fig_save_path+self.exp_type+'.png',format ='png')


        elif self.exp_type == 'influ_SF':
            self.influencer(nw_type='SF')
            self.save_self()

            f = pl.figure()
            pl.plot(self.data['bmult'],self.data['xms'],'o-')
            pl.title('Effect of targeted promotion - SF')
            pl.ylabel('Average belief')
            pl.xlabel('Spending multiplier')
            f.savefig(self.fig_save_path+self.exp_type+'.png',format ='png')

        elif self.exp_type == 'example_ts':
            self.example_ts()
            self.save_self()


    def save_self(self):
        path = os.getcwd() + '/data/'
        if not os.path.exists(path):
            os.makedirs(path)
        pickle.dump(self.data,open(path+self.exp_type,'wb'))

    def example_ts(self):

        nexa = 3
        T = 10000
        xms = np.zeros((T,nexa))
        bs = [10.,3.,10.]
        qs = [1.,1.,0.5]

        for i in range(len(bs)):
            xms[:,i] = self.run(T = T, b = bs[i], p_i = 0.5, q = qs[i])

        self.data['xms'] = xms
        self.data['bs'] = xms
        self.data['qs'] = qs

        f = pl.figure()
        for i in range(len(bs)):
            pl.subplot(3,1,i)
            pl.plot(xms[:,i],label = 'b = '+str(bs[i]) + ' q = '+str(qs[i]))
            leg = pl.legend(loc=4, fancybox=True)
            leg.get_frame().set_alpha(0.5)

        f.savefig(self.fig_save_path+self.exp_type+'.png',format ='png')


    def initial_cons(self, p = 1., q = 1., n_seeds = 1):

        pi = np.linspace(0.01,0.99,num = 20)
        seeds = np.arange(0,n_seeds)
        xms = np.zeros((len(pi),len(seeds)))

        for i in range(len(pi)):
            print(i)
            for j in range(len(seeds)):
                xm = self.run(p_i = pi[i], seed = seeds[j] , p= p, q = q)
                tf = int(len(xm)*0.5)
                xms[i,j] = np.mean(xm[tf:])

        self.data['xms'] = np.mean(xms,axis=1)
        self.data['pi'] = pi

        #pl.figure()
        #pl.plot(self.data['pi'],self.data['xms'])
        #pl.show()

    def find_pic(self):
        pic = 0
        for i in range(len(self.data['pi'])):
            if self.data['xms'][i] > 0.:
                pic = self.data['pi'][i]
                break

        return pic

    def pic(self):

        q = np.linspace(0.5,1.,num=20)
        pic = np.zeros(len(q))
        for i in range(len(q)):
            print(i)
            self.initial_cons(q = q[i] , n_seeds= 10)
            pic[i] = self.find_pic()

        self.data['q'] = q
        self.data['pic'] = pic

    def influencer(self, nw_type = 'ER'):

        pi = 0.1
        if nw_type == 'ER':
            b_mults = np.linspace(1.,3.,num = 20)
        elif nw_type == 'SF':
            b_mults = np.linspace(1.,5.,num = 20)
        seeds = np.arange(0,5)
        xms = np.zeros((len(b_mults),len(seeds)))
        for i in range(len(b_mults)):
            print(i)
            for j in range(len(seeds)):
                xm = self.run(p_i = pi, seed = seeds[j], scale = 0.1,b_mult = b_mults[i], T = 40000, bias_on=True, nw_type= nw_type)
                tf = int(len(xm)*0.5)
                xms[i,j] = np.mean(xm[tf:])

        self.data['xms'] = np.mean(xms,axis=1)
        self.data['bmult'] = b_mults
        self.data['nw_type'] = nw_type


    def update(self,i,W,x,mu,b = 2., p = 1., q = 1.):

        n_q = len(x[x == -1.])
        n_p = len(x[x == 1.])
        ind = np.zeros((1,len(x)))
        ind[0,x == 1.] = np.random.binomial(1,p,size = n_p)
        ind[0,x == -1.] = np.random.binomial(1,q,size = n_q)
        w = W[i,:]*ind
        n = np.count_nonzero(w)
        if n > 0:
            s = w.dot(x)/n + mu[i]
        else:
            s = mu[i]
        P = 1./(1+np.exp(-b*s))
        x[i] = 2*( np.random.binomial(1,P) - 0.5)

        return x

    def run(self,N = 100, seed = 1, T = 1000, b = 10., p_i = 0.5, scale = 0.1, b_mult = 1., bias_on = False, rho = 4./100, nw_type = 'ER', p = 1., q = 1.):

        np.random.seed(seed)

        mu = np.zeros(N)
        x = 2*( np.random.binomial(1,p_i,size = N) - 0.5)

        x_m = np.zeros(T)

        promo = np.zeros(N)
        quash = np.ones(N)

        b_promo = scale*N
        b_quash = b_mult*scale*N
        c = 1
        n_max = 10

        if nw_type == 'ER':
            W = np.array(nx.adjacency_matrix(nx.erdos_renyi_graph(N,rho,seed = seed)))
        elif nw_type == 'SF':
            W = np.array(nx.adjacency_matrix(nx.barabasi_albert_graph(N,2,seed = seed)))

        if bias_on:
            k = np.sum(W,axis=1)
            idx_max = np.argsort(-k)[:n_max]
            promo[idx_max] = b_promo/(c*n_max)
            quash = quash*(-b_quash)/(c*N)
            mu = promo + quash

        for t in range(T):

            idx = np.random.randint(0,N)
            x = self.update(idx,W,x,mu,b = b, p = p, q = q)
            x_m[t] = np.mean(x)

        tf = int(T*0.5)
        var = np.std(x_m[tf:])

        if var > 5*10**(-2):
            print('Not converged, var = '+str(var))

        #pl.figure()
        #pl.plot(x_m)
        #pl.show()

        return x_m

#spin = Spin_doctor_model(exp_type='initial')
#spin = Spin_doctor_model(exp_type='pic')
#spin = Spin_doctor_model(exp_type='influ_ER')
spin = Spin_doctor_model(exp_type='influ_SF')
#spin = Spin_doctor_model(exp_type='example_ts')
spin.do_exp()
