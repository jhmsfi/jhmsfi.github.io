globals [
  dead-people
  avg-dead-people
  ticks
]

patches-own [
  burned?         ;; has this tree burned yet?
  exit            ;; indicates a non-burning exit
  fire-coming     ;; indicates a fire is coming
]

turtles-own [
  saw-fire?
  safe-move?
  move-rate
]

to setup
  ca
  ask patches
    [ set burned? false
      set exit false
      set fire-coming 0
      ;; put a wall around the room to prevent "wrapping"
      if (pxcor = (0 - screen-edge-x)) or
         (pycor = (0 - screen-edge-y)) or
         (pycor = screen-edge-y) or
         (pxcor = screen-edge-x)
        [ set pcolor blue ]
      
      ;; put in exit
      if (pycor = 0) and (pxcor = screen-edge-x) [ 
          set pcolor black 
          set exit true]
   
      ;; make a column of burning trees
      if pcolor != blue and pxcor = (1 - screen-edge-y) and pycor = 0 
        [ set pcolor red
          set burned? true ] ]
  set dead-people 0
  set ticks 0

  crt 20

  ask turtles [
    setxy ((random ((screen-edge-x * 2) - 1)) - (screen-edge-x - 1)) ((random ((screen-edge-y * 2) - 1)) - (screen-edge-y - 1))
    set saw-fire? false
    ifelse (considerate-people?) [
        set move-rate 1
    ]
    [
        set move-rate 2
    ]    
  ]
end

to move-towards-exit
    set safe-move? false
    ifelse any neighbors with [exit = true] [
        set heading towardsxy-nowrap 11 0
        fd move-rate
    ]
    [ 
      set heading towardsxy-nowrap 10 0
      fd move-rate
    ]
    repeat 36 [
        if burned?-of patch-here = false [
            if pcolor-of patch-here = black [
                set safe-move? true
            ]
        ]
        if safe-move? = false [
            bk move-rate
            rt 10
            fd move-rate
        ]
    ]
end

to move-turtles
    ask turtles [
        if (exit-of patch-here = false) [
            if any neighbors with [burned? = true] or saw-fire? = true or fire-coming-of patch-here > 0 [
                move-towards-exit
                set saw-fire? true
            ]
            if (considerate-people? and saw-fire?) [
                ifelse (yell?) [
                    ask patch-here [
                        set fire-coming 1
                    ]   
                 ]
                 [
                     ask other-turtles-here [
                         set saw-fire? true
                     ]
                 ]
            ] 
        ]
    ]
end

to go
  if not any patches with [pcolor = black and exit != true] [
    stop
  ]
  if considerate-people? [
      diffuse fire-coming 1
  ]
  ask patches with [pcolor = red] [
     
     ask neighbors with [burned? = false and pcolor != blue and exit != true]
        [ if random 100 < fireSpread
           [ 
               set pcolor red 
               set burned? true 
            ] 
         ] 
   ]
   ask turtles [
       if burned?-of patch-here = true [
           die
       ]
   ]
   move-turtles
   set dead-people 20 - count turtles
   set ticks ticks + 1
end

to batch-run
    locals [running-total]
    set avg-dead-people 0

    repeat number-of-runs [
        setup
        repeat length-of-runs [
            go
        ]
        set running-total running-total + dead-people
        set avg-dead-people running-total / number-of-runs
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
257
10
428
202
11
11
7.0
1
10
0
0

CC-WINDOW
5
313
252
469
Command Center

BUTTON
137
54
206
90
go
go
T
1
T
OBSERVER

BUTTON
57
54
127
90
setup
setup
NIL
1
T
OBSERVER

MONITOR
64
200
162
249
Dead People
dead-people
3
1

MONITOR
471
25
528
74
ticks
ticks
3
1

BUTTON
101
19
198
52
Batch Run
batch-run
NIL
1
T
OBSERVER

MONITOR
236
231
393
280
Average Dead People
avg-dead-people
3
1

SLIDER
552
168
724
201
number-of-runs
number-of-runs
0
100
100
1
1
NIL

SLIDER
551
220
723
253
length-of-runs
length-of-runs
0
100
50
1
1
NIL

SLIDER
557
278
729
311
fireSpread
fireSpread
0
100
50
1
1
NIL

BUTTON
115
109
178
142
step
go
NIL
1
T
OBSERVER

SWITCH
492
387
687
420
Considerate-People?
Considerate-People?
0
1
-1000

SWITCH
509
466
665
499
Yell?
Yell?
0
1
-1000

@#$#@#$#@
WHAT IS IT?
-----------
This project simulates the spread of a fire through a room.


HOW TO USE IT
-------------
Click the SETUP button to set up the people (multi-colored) and fire (red on the left-hand side).

Click the GO button to start the simulation.  The simulation will stop when all possible squares have burned.

Click the STEP button to execute one step of the model.

Click the BATCH-RUN button to execute the model for length-of-runs timesteps, number-of-runs, this is the only button which will update average-dead-people.

THINGS TO NOTICE
----------------
The blue "walls" prevent the fire from spreading off the edges of the screen.  The fire spreads with rate fireSpread, which can be controlled by the slider.  Agents are initially scattered randomly across the grid and remain stationary unless they are next to a fire or they have been yelled at or nudged (as explained below).  If they know there is a fire in the room, then they move directly towards the exit, unless the fire stands in their way, in which case they turn to the right 10 degrees and try and move in that direction.  This continues for a full circle, if they are surrounded by the fire they remain stationary.

Number-of-runs controls the number of times the model is run when the BATCH-RUN button is pressed.

Length-of-runs controls the number of steps the model is executed for when BATCH-RUN is pressed.

If Conisderate-people? is turned on, then agents will either Yell or Nudge other agents to let them know a fire is coming.

If Yell? is turned on and Considerate-people? is turned on then agents set a variable in the current patch, called fire-coming to 1 and this variable diffuses throughout the grid.

If Yell? is turned off but Considerate-people? is turned on then agents will nudge any agents that they pass by (are in the same patch) on their way to the exit.

Dead-people is the number of agents that have been consumed by the fire.

Avg-dead-people is the average over multiple runs and is only calculated when the batch-run button is pressed.

EXTENDING THE MODEL
-------------------

NETLOGO FEATURES
-----------------

CREDITS AND REFERENCES
----------------------
Based on the forest fire model developed by Resnick and WIlensky, as listed below.

This model was developed at the MIT Media Lab. See Resnick, M. (1994) "Turtles, Termites and Traffic Jams: Explorations in Massively Parallel Microworlds." Cambridge, Ma: MIT Press. Adapted to StarLogoT, 1997, as part of the Connected Mathematics Project. Adapted to NetLogo, 2000, as part of the Participatory Simulations Project.

To refer to this model in academic publications, please use: Wilensky, U. (1998).  NetLogo Fire model. http://ccl.northwestern.edu/netlogo/models/Fire. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
@#$#@#$#@
default
true
0
Polygon -7566196 true true 150 5 40 250 150 205 260 250

@#$#@#$#@
NetLogo 1.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
