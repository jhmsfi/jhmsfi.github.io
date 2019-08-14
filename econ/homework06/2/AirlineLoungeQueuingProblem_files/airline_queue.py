#!/usr/bin/python2.4
import sys, random
N=100 # number of agents
sample=1; MC=10000000
time_update = 2 #Default entry frequency
delay=2
ID={}; tol={}; wT={}
lounge=[]; tmpID=[]; line_len={}; nJoin={}; que=[]; preI=-1
def distribution(tol,N,width):
	dist={}
	for i in range(N):
		where=(int(tol[i]/width)+0.5)*width
		if not dist.has_key(where):
			dist[where]=1
			continue
		dist[where]=dist[where]+1
	index=dist.keys()
	index.sort()
	for i in index:
		print i, dist[i]

for i in range(N):
	tmpID.append(i) #randomly assigning ID to agents
	lounge.append(i)

for s in range(sample):
	#initialisation
	random.shuffle(tmpID)
	for i in range(N):
		tol[i]=random.random()*50
		#tol[i]=random.gauss(25,10)
		if tol[i]<0: tol[i]=-tol[i]
		ID[i]=tmpID[i]
		lounge[i]=tmpID[i]

	line_len[0]=0; nJoin[0]=0; flag=0; preI=-1
	for t in range(MC): # t round
		t=t+1
		random.shuffle(lounge)
		nJoin[t]=0; 
		for i in lounge:
			if tol[i]>len(que): #joining queue
				if flag==0:  # the first enterance
					wT[i]=time_update; flag=1; 
				else: #reversed order is considered
					wT[i]=time_update+wT[preI]+delay*bool(ID[i]>ID[preI])
				preI=i
				que.append(i)
				nJoin[t]=nJoin[t]+1
				lounge.remove(i) # 'i' moved out of lounge
		if len(que)==0:
			if len(lounge)==0: 
				break
		else:
			if t>=wT[que[0]]:
				que.pop(0)
		line_len[t]=len(que)

	for i in range(t):
		print line_len[i], nJoin[i]
	print "\n\n"
	print "\n\n"
	distribution(wT,N,10)
