#file to simulate fire in rooms
#kevin lochner 7/18/03
#room is 2D, positions in room are in (x,y) format

from random import random,seed
import time,os,sys
seed(3)

#run a sequence of game simulations (numruns) with specified params
def test(numpeople,fireloc,doorloc,xlen,ylen,numruns) :
    results  = []
    print "seed, len to exit, num iterations, num dead, num alive"
    for i in range(numruns) :
        seed(i)
        (totalLen,numiters,dead,alive) = FieryRoom(numpeople,fireloc,doorloc,xlen,ylen).run()
        results.append((i,totalLen,numiters,dead,alive))
    for elem in results :
        print elem[0],elem[1],elem[2],elem[3],elem[4]


#functions to allow access of 2D array with (x,y) location
def getElem(twoDArray,locTuple) :
    return twoDArray[locTuple[0]][locTuple[1]]

def setElem(twoDArray,locTuple,val) :
    twoDArray[locTuple[0]][locTuple[1]] = val

  
#agent that is placed in room, type not currently used
class Agent :
    def __init__(self,loc,type) :
        self.loc = loc
        self.type = type
        self.bestPath = []

    #calculate best move for agent in room
    def bestMove(self,room) :
        if self.loc == room.doorloc :
            return None,None

        if len(self.bestPath) < 2  or not room.validPath(self.bestPath) :
            self.bestPath = room.shortestPath(self.loc,0)

        if not self.bestPath :
            while 1 :
                xdelta = int(random()*3)-1
                ydelta = int(random()*3)-1
                newpos = (self.loc[0]+xdelta,self.loc[1]+ydelta)
                if not room.inroom(newpos) :
                    continue
                self.bestPath = [self.loc,newpos]
                break    
        return len(self.bestPath),self.bestPath[1]
        
    #adjust internal state to make best move, return move
    def move(self,room) :
        if self.bestPath == [] :
            self.bestPath = room.shortestPath(self.loc)
        self.loc = self.bestPath[1]
        self.bestPath = self.bestPath[1:]
        return self.loc

#fire is like agent, but expands rather than moving
class Fire :
    def __init__(self,loc) :
        self.loc = [loc]
        
    def spread(self,room) :
        pos = self.loc[int(random()*len(self.loc))]
        openSpaces = []
        while len(openSpaces) == 0 :
            openSpaces = []
            pos = self.loc[int(random()*len(self.loc))]
            for i in [-1,0,1] :
                for j in [-1,0,1] :
                    newpos = (pos[0]+i,pos[1]+j)
                    if getElem(room.room,newpos)[0] != "*" and \
                       getElem(room.room,newpos)[0] != "X" and \
                       newpos != room.doorloc :
                        openSpaces.append(newpos)
        newpos = openSpaces[min(int(random()*len(openSpaces)),\
                                len(openSpaces)-1)]
        self.loc.append(newpos)
        return newpos


#room class, keeps track of own internal state,
#maintains list of agents and fire,
#run() will advance the room until no agents remain
class FieryRoom :
    def __init__(self,numPeople,fireloc,doorloc,xrange,yrange) :
        os.system("clear")
        print "loading "
        self.room = {}
        self.numdead = 0
        self.numexited = 0
        self.doorloc = doorloc
        self.Fire = Fire(fireloc)
        self.xrange = xrange
        self.yrange = yrange
        self.agents = []
        for i in range(xrange) :
            self.room[i] = {}
            for j in range(yrange) :
                if i == 0 or j == 0 or i == xrange-1 or j == yrange - 1 :
                    self.room[i][j] = ("X",None)
                else :
                    self.room[i][j] = (" ",None)

        #set the locations of the door and the fire
        setElem(self.room,self.doorloc,(" ",None))
        setElem(self.room,fireloc,("*",Fire(fireloc)))

        #create the people
        loadstr = "loading "
        self.totalLentoExit = 0
        for i in range(numPeople) :
            os.system("clear");print loadstr;loadstr = loadstr + " # "
            valid = 0
            while not valid :
                xloc = int(random()*self.xrange)
                yloc = int(random()*self.yrange)
                if self.inroom((xloc,yloc)) and self.room[xloc][yloc][0] == " " :
                    newagent = Agent((xloc,yloc),0)
                    (length,move) = newagent.bestMove(self)
                    self.agents.append(newagent)
                    self.room[xloc][yloc] = ("A",newagent)
                    valid = 1
                    if length :
                        self.totalLentoExit = self.totalLentoExit + length

    #print the room to screen
    def printRoom(self) :
        for i in range(self.yrange) :
            line = ""
            for j in range(self.xrange) :
                line = line + self.room[j][i][0]
            print line
        print "Exited: ",self.numexited
        print "Dead: ",self.numdead

    #clock the room state and print the room (refresh screen)
    def run(self) :
        numclocks = 0
        while 1:
            numclocks = numclocks + 1
            os.system("clear")
            self.printRoom()
            self.clock()
            time.sleep(1)
            if len(self.agents) == 0 :
                os.system("clear")
                self.printRoom()
                return (self.totalLentoExit,numclocks,self.numdead,self.numexited)

    #is <loc> inside the room, or equal to the door
    def inroom(self,loc) :
        if loc == self.doorloc :
            return 1
        if loc[0] < 1 or loc[0] >= self.xrange-1 :
            return 0
        if loc[1] < 1 or loc[1] >= self.yrange-1 :
            return 0
        return 1
    
   #is <loc> a valid position with no fire within one square
    def nofire(self,loc) :
        for i in [-1,0,1] :
            for j in [-1,0,1] :
                newpos = (loc[0]+i,loc[1]+j)
                if not self.inroom(newpos) :
                    continue
                if getElem(self.room,newpos)[0] == "*" : return 0
        return self.inroom(loc)

    #is <loc> currently not occupied by someone else or by fire
    def isopen(self,loc) :
        if not self.inroom(loc) : return 0
        if not self.nofire(loc) : return 0
        if getElem(self.room,loc)[0] == " " : return 1
        return 0
    
    #is there no fire infringing on the given path
    def validPath(self,path) :
        for loc  in path :
            if not self.nofire(loc) : return 0
        return 1

    #perform BFS to find shortest path from <pos> to the door
    def shortestPath(self,pos,verbose) :
        toProcess = [(pos,[])]
        visited = {}
        for i in range(21) :
            visited[i] = {}
            for j in range(21) :
                visited[i][j] = 0
        setElem(visited,pos,1)
        while 1:
            if len(toProcess) == 0 :
                return None
            if verbose == 1 :
                loc = toProcess[0]
                str  = "(%s,%s) --->    "%(loc[0][0],loc[0][1])
                if len(toProcess) > 1 :
                    for loc in toProcess[1:] :
                        str = str + "(%s,%s)"%(loc[0][0],loc[0][1])
                str = str + " ||| "
            loc = toProcess[0][0]
            oldpath = toProcess[0][1][:]
            oldpath.append(loc)
            if loc == self.doorloc :
                return oldpath
            toProcess = toProcess[1:]
            for i in [-1,0,1] :
                for j in [-1,0,1] :
                    if i == 0 and j == 0 : continue
                    newloc = (loc[0]+i,loc[1]+j)
                    if verbose  == 1:
                        str = str + "(%s,%s,%s,%s)"%(newloc[0],newloc[1],self.nofire(newloc),\
                                                    getElem(visited,newloc))
                    if self.nofire(newloc) and getElem(visited,newloc) == 0:
                        toProcess.append((newloc,oldpath))
                        setElem(visited,newloc,1)
            if verbose == 1 :
                open("debug.log",'a').write(str+"\n")


    #advance the state of the room by one timestep
    def clock(self) :
        #record positions of agents before update
        blocked = {}
        for i in range(self.xrange) :
            blocked[i] = {}
            for j in range(self.yrange) :
                if getElem(self.room,(i,j)) == "A" :
                    setElem(blocked,(i,j),1)
                else  :
                    setElem(blocked,(i,j),0)
                    
        if len(self.agents) == 0 :
            sys.exit(1)
        newfireloc = self.Fire.spread(self)
        #the following will make agents "decide" on next move
        for agent in self.agents:
            if agent.loc == self.doorloc :
                continue
            else :
                agent.bestMove(self)

                    
        #adjust the fire
        setElem(self.room,newfireloc,("*",self.Fire))

        #move the agents
        for agent in self.agents :
            if agent.loc == self.doorloc :
                self.agents.remove(agent)
                setElem(self.room,self.doorloc,(" ",None))
                print "agent exited"
                self.numexited = self.numexited + 1
                continue
            length,newpos = agent.bestMove(self)
            if getElem(self.room,newpos)[0] == "*" :
                print "agent died"
                self.numdead = self.numdead + 1
                self.agents.remove(agent)
                setElem(self.room,agent.loc,(" ",None))
                continue
            if getElem(self.room,newpos)[0] != "A" and \
               getElem(blocked,newpos) == 0:
                setElem(self.room,agent.loc,(" ",None))
                agent.move(self)
                setElem(self.room,newpos,("A",agent))
        
        
        
        
        
