globals 
[ 
   ticks    ; time steps
   credFollow ; credit for following (to est)
   lead     ; leader gets credit equal to credFollow * lead
   i        ; dumb place holder
   j        ; dumber place holder
   k        ; yet another place holder
   force    ; counter for #spaces forced back b/c space is occupied
   numFinish ; number of bikers across the finish line
   nt        ; number of tortoises
   nh        ; number of hares
   nf        ; number of free-riders
   theWinner ; breed (strategy) of winning biker
   total_rank_t ;sum of ranks of breed tortoise
   total_rank_h ;sum of ranks of breed tortoise
   total_rank_f ;sum of ranks of breed tortoise
   final_rank_t ;final sum of ranks of breed tortoise
   final_rank_h ;final sum of ranks of breed tortoise
   final_rank_f ;final sum of ranks of breed tortoise
   energy_up_bound ;upper bound for uniformly distributed eave - same for all breeds
                   ;(eave = average available energy per trial/time step) 
   vfMultiplier   ; multiplier for agents (all breeds/strategies): vf = vfMultiplier * eave
   tortVfEndGame  ; multiplier of vf to increase visibility for tortoises at endgame 
]

turtles-own 
[ 
  eave      ; incremental available energy per trial/time step 
  est       ; energy stock at time t
  pt        ; position (in unidimensional space) at time t
  vf        ; forward visibility measured in unidimensional space
  move      ; amount to move forward in time step
  d_move    ; amount biker desires to move (may be limited by vf)
  prevPt    ; previous position
  toFollow  ; boolean, 1 if there is someone to follow, 0 else
  rank      ; final rank
] 

breeds [tortoise hare freeRider]

;;; 
;;; SETUP AND HELPERS
;;;          
to setup 
  ca
  set ticks 0
  set credFollow Follower_Energy_Credit
  set lead Leader_Energy_Credit
  set tortVfEndGame Multiplier_Tort_Vf_atEndGame
  set vfMultiplier Forward_Visibility_Multiplier
  set force 0
  set numFinish 0  ; counter for n. of agents that crossed the finish line
  set nt Number_of_Tortoises
  set nh Number_of_Hares
  set nf Number_of_Free_Riders
  set energy_up_bound Energy_upper_Bound ;upper bound on uniformly distributed eave
  ask patches [ setup-road ]
  setup-bikers  
  set total_rank_t 0
  set total_rank_h 0
  set total_rank_f 0
  set final_rank_t 0
  set final_rank_h 0
  set final_rank_f 0

  setup-plots
  update-plots
end

to setup-road 
  if ( pycor < 2 ) and ( pycor > -2 ) [ set pcolor white set plabel pxcor ] 
  if ( pxcor = 0 ) [ set pcolor red set plabel pxcor ] 
end

to setup-bikers
  locals [n nty nfy nhy]
  set-default-shape turtles "bike"
  set n nt + nf + nh
  set nty nt
  set nfy nf
  set nhy nh
  ;agent creation and move order - agents move in a sequence T FR H  T FR H ...
  while [n != 0 ] [
    if nty > 0 [createTortoise set nty nty - 1 set n n - 1]
    if nfy > 0 [createFreeRider set nfy nfy - 1 set n n - 1]
    if nhy > 0 [createHare set nhy nhy - 1 set n n - 1]
    ]
end

to createHare  
  create-custom-hare 1 [
    set color grey
    set xcor -1 * screen-edge-x
    set ycor 0        ; start all bikers at 0,0
    set heading  90
    set eave 1 + random energy_up_bound
    set est 0
    set pt 0
    set vf vfMultiplier * eave
    set move 0
    set d_move 0
    set prevPt 0
    set toFollow 0
    set rank 0
  ]
  end
  
  to createFreeRider
    create-custom-freeRider 1 [
    set color pink
    set xcor -1 * screen-edge-x
    set ycor 0        ; start all bikers at 0,0
    set heading  90
    set eave 1 + random energy_up_bound
    set est 0
    set pt 0
    set vf vfMultiplier * eave
    set move 0
    set d_move 0
    set prevPt 0
    set toFollow 0
    set rank 0
  ]
  end
  
  to createTortoise
    create-custom-tortoise 1 [
    set color green
    set xcor -1 * screen-edge-x
    set ycor 0        ; start all bikers at 0,0
    set heading  90
    set eave 1 + random energy_up_bound
    set est 0
    set pt 0
    set vf vfMultiplier * eave
    set move 0
    set d_move 0
    set prevPt 0    
    set toFollow 0
    set rank 0
  ]
end

;;;
;;; GO AND HELPERS
;;;
to go
 ;; set ticks ticks + 1
  ask turtles [ set label who] 
  
  ;Note on Space/Coordinates - the race is run on the integer space [- screen-edge-x, ..., 0]
  ;from left to right, with 0 as the finish line.
  
  ;Move methods
  ask turtles [ if breed = tortoise [
    without-interruption [
    set prevPt xcor
     
    ifelse -1 * prevPt >= tortVfEndGame * vf 
      ;; end game / switch to hare - sprint (use all est) if end is in sight (max of x*vf)
      [set d_move xcor + eave + est
      set xcor d_move
      while [any? other-turtles-here] [ bk 1 set k k + 1]  ; move back spaces until you find an empty space
      if k > eave [set xcor prevPt]  ; don't go backward
      set k 0                         ; reset i
      set move xcor - prevPt
      set est est - (move - eave)
      if any? turtles-at 1 0 [set est est + credFollow]
      if not any? turtles-at 1 0 and any? turtles-at -1 0 [set est est + lead * credFollow]  ]
      
     ;; tortoise the agent doesn't see the finish line - normal move
    [set d_move xcor + eave
    ifelse vf < d_move - prevPt [set xcor prevPt + vf] [set xcor d_move]
    while [any? other-turtles-here] [ bk 1 set k k + 1]  ; move back spaces until you find an empty space
    ;; the tortoise wastes stored energy earned by following (just don't use it)
    ;; may want to allow them to sprint in the end using any stored energy
    ;; update prevPt:
    if k > eave [set xcor prevPt]  ; don't go backward
    set k 0   
    ;; accumulate est for the endgame
    if any? turtles-at 1 0 [set est est + credFollow]
    if not any? turtles-at 1 0 and any? turtles-at -1 0 [set est est + lead ] ]
    
    ;check if crossed finish line
     if xcor  > 0  [set numFinish numFinish + 1
     set rank numFinish
     set final_rank_t final_rank_t + rank ;increment the total breed rank
     if rank = 1 [set theWinner tortoise]
     if xcor > 0   [die]]
  ]]]
 
   ask turtles [ if breed = hare [
    without-interruption [
    set prevPt xcor
    set d_move xcor + eave + est
    ifelse vf < d_move - prevPt [set xcor prevPt + vf] [set xcor d_move]
    while [any? other-turtles-here] [ bk 1 set k k + 1]  ; move back spaces until you find an empty space
    if k > eave [set xcor prevPt]  ; don't go backward
    set k 0                         ; reset i
    set move xcor - prevPt
    set est est - (move - eave)
    if any? turtles-at 1 0 [set est est + credFollow]
    if not any? turtles-at 1 0 and any? turtles-at -1 0 [set est est + lead ] 
    
    ;check if crossed finish line
    if xcor  > 0  [set numFinish numFinish + 1
    set rank numFinish
    set final_rank_h final_rank_h + rank ;increment the total breed rank
    if rank = 1 [set theWinner hare]
    if xcor > 0   [die]]
  ]]]

  ask turtles [ if breed = freeRider [
    without-interruption [
    ;; free-riders want to find the follower position in the furthest pack that they can reach/join
    ;; if there is no pack they move eave (tortoise/conservative move).
    set prevPt xcor
    set d_move prevPt + eave + est
    if vf < d_move - prevPt [set d_move prevPt + vf]  ; can't move entire desired amount b/c out of visibility
    ;; is there a pack they can join?
    set toFollow 0
    set i d_move + 1
    while [toFollow = 0 ] [  ; while haven't found someone to follow 
      if any? turtles-at i 0  [set toFollow 1 ]
      set i i - 1
      ]
    ;; there is someone to follow (a pack) - move to the back of it as long as it's not behind you.
    ifelse (toFollow = 1 and i > prevPt) [set xcor d_move] [set xcor (prevPt + eave) ]
    while [any? other-turtles-here] [ bk 1 set k k + 1]  ; move back spaces until you find an empty space
    if k > eave [set xcor prevPt]  ; don't go backward
    set k 0                         ; reset i
    set move xcor - prevPt
    set est est - (move - eave)
    if any? turtles-at 1 0 [set est est + credFollow]
    if not any? turtles-at 1 0 and any? turtles-at -1 0 [set est est + lead ] 

    ;check if crossed finish line
    if xcor  > 0  [set numFinish numFinish + 1
    set rank numFinish
    set final_rank_f final_rank_f + rank ;increment the total breed rank
    if rank = 1 [set theWinner freeRider]
    if xcor > 0   [die]]
  ]]]
  
  if numFinish = nt + nh + nf [stop]
  
  ;Update Ranks
  update-ranks
  ;Activate Plots
  setup-plots
  update-plots
  ;End of Period Clean-up
  clean-up
end

to update-ranks
  ;Note: ask patches -  the patches are scheduled for execution by row: 
  ; left to right within each row, and starting with the top row. 
  ; This means that the search starts at the "start line" of the race.
  locals [rank_counter]
  set rank_counter nt + nh + nf;
  ask patches with [any? tortoise-here] 
     [set rank_counter rank_counter - 1 set total_rank_t  total_rank_t + rank_counter]
  ask patches with [any? hare-here] 
     [set rank_counter rank_counter - 1 set total_rank_h  total_rank_h + rank_counter]    
  ask patches with [any? freeRider-here] 
     [set rank_counter rank_counter - 1 set total_rank_f  total_rank_f + rank_counter]
end

to clean-up
  set total_rank_t 0
  set total_rank_h 0
  set total_rank_f 0
end

;;;
;;; PLOT
;;;

to-report Winner_Breed
  report theWinner
end

to-report avg_final_rank_t
  report (final_rank_t / nt )
end

to-report avg_final_rank_h
  report (final_rank_h / nh )
end

to-report avg_final_rank_f
  report (final_rank_f / nf )
end

to setup-plots
  set-current-plot "Breed Distribution"
  set-plot-x-range 0 screen-edge-x
  set-plot-y-range 0 (nt + nh + nf)  

  set-current-plot "Average Rank per Breed"
  set-plot-x-range 0 screen-edge-x
  set-plot-y-range 0 (nt + nh + nf) 
end

to update-plots
  update-breed-plot
  update-average_rank-plot
end

;; Plot of the n. of agents with each strategy (breed)
to update-breed-plot
  set-current-plot "Breed Distribution"
  set-current-plot-pen "T"
  if nt > 0 [plot count turtles with [breed = tortoise] ]
  set-current-plot-pen "H"
  if nh > 0 [plot count turtles with [breed = hare] ]
  set-current-plot-pen "FR"
  if nt > 0 [plot count turtles with [breed = freeRider] ]
end

;Plot of average rank of agents in the race space
to update-average_rank-plot
  set-current-plot "Average Rank per Breed"
  set-current-plot-pen "T"
  if nt > 0 [ plot ( total_rank_t / nt ) ]
  set-current-plot-pen "H"
  if nh > 0 [ plot ( total_rank_h / nh ) ]
  set-current-plot-pen "FR"
  if nf > 0 [ plot ( total_rank_f / nf ) ]
end

;This attempt of a scatter plot of individual ranks isn't working
to update-individual_rank-plot
  set-current-plot "Individual Ranks"
  ;set-plot-pen-mode pen-mode
  ;set-plot-pen-interval bar-width
  ;set-plot-pen-color breed-a-bar-color
  Ask turtles
    [ if breed = tortoise [ set-current-plot-pen "T" set-plot-pen-color green plot rank]
      if breed = hare [ set-current-plot-pen "H" set-plot-pen-color gray plot rank]
      if breed = freeRider [ set-current-plot-pen "FR" set-plot-pen-color red plot rank]
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
4
10
1497
103
200
8
3.7
0
9
0
0
0

CC-WINDOW
238
489
533
679
Command Center

BUTTON
5
120
77
161
NIL
setup
NIL
1
T
OBSERVER
T

BUTTON
82
120
153
160
NIL
go
T
1
T
OBSERVER
NIL

MONITOR
478
113
601
162
Winner's Strategy
Winner_Breed
3
1

PLOT
6
273
244
465
Breed Distribution
Time
n. of agents
1.0
100.0
0.0
100.0
false
true
PENS
"T" 1.0 0 -11352576 true
"H" 1.0 0 -7566196 true
"FR" 1.0 0 -65536 true

PLOT
251
273
481
466
Average Rank per Breed
Time
Average Rank
1.0
100.0
0.0
100.0
false
true
PENS
"T" 1.0 0 -11352576 true
"H" 1.0 0 -7566196 true
"FR" 1.0 0 -65536 true

SLIDER
3
166
242
199
Number_of_Tortoises
Number_of_Tortoises
0
100
10
1
1
NIL

SLIDER
4
198
243
231
Number_of_Hares
Number_of_Hares
0
100
10
1
1
NIL

SLIDER
5
228
243
261
Number_of_Free_Riders
Number_of_Free_Riders
0
100
10
1
1
NIL

SLIDER
246
164
447
197
Follower_Energy_Credit
Follower_Energy_Credit
0
5
2.0
0.2
1
NIL

SLIDER
245
197
447
230
Leader_Energy_Credit
Leader_Energy_Credit
0
5
0.8
0.2
1
NIL

SLIDER
245
229
448
262
Energy_upper_Bound
Energy_upper_Bound
0
100
5
1
1
NIL

MONITOR
610
112
775
161
T - Average Final Rank
avg_final_rank_t
3
1

MONITOR
610
161
775
210
H - Average Final Rank
avg_final_rank_h
3
1

MONITOR
610
209
775
258
FR - Average Final Rank
avg_final_rank_f
3
1

SLIDER
526
277
761
310
Multiplier_Tort_Vf_atEndGame
Multiplier_Tort_Vf_atEndGame
0
5
2.0
0.2
1
NIL

SLIDER
530
313
753
346
Forward_Visibility_Multiplier
Forward_Visibility_Multiplier
0
5
3.0
0.2
1
NIL

@#$#@#$#@
----------
----------
Go Lance! 
----------
----------

This model and documentation was written by Kristen Hassmiller and Rodolfo Sousa.

The assignment:
---------------
Consider the following situation:

A group of, say, 20 bike riders are competing in a long road race. In any pack of riders, the leader provides a big benefit to the other riders in the pack, and also receives a slight advantage over riding alone. What happens?

1. Model, using whatever techniques you wish, the above scenario.
2. Explicitly state your model and key assumptions.
3. Summarize key results.
4. Suggest some potentially interesting future directions and questions for the model.
5. Suggest some standard social science scenarios that could be usefully modeled using such a process.

How our model works (quick summary):
------------------------------------
This project models the movement of bike riders competing in a long road race. Each biker follows a simple set of rules, defined by its strategy (tortoise, hare, free-rider), defined below.  The program was written in NetLogo, and is available to download from this page.  The applet can be run directly to explore the model.

The model facilitates exploration of the impact of biker strategy and ability on outcome, as well as cooperation behavior (the formation of packs).

HOW TO USE IT
-------------
Click on the SETUP button to set up the bikers. Set the NUMBER slider to change the number of bikers assuming each strategy.  (NOTE: Update to reflect actual model.)

Click on GO to start the bike riders moving.  Note that you made need to scroll to the right to follow the riders as they progress beyond the edge of your screen (the race may be longer than your screen). 

MODEL DETAILS: The Road
-----------------------
In this model, the road is broken into unit spaces.  Except for the starting space, two bikers can never occupy the same space.  The road is one space wide, so bikers can only pass if they have enough ability to overtake all bikers in front of them.  

MODEL DETAILS: Biker Variables
------------------------------
color 		color					based on strategy (or breed)
eave 		energy on average (reflects ability)	1 + random 10
est 		energy stock at t			initialized to zero, acc
vf 		forward visibility			4 * eave
move 		where biker moves in a time step	
d_move 		where biker desires to move		
prevPt 		where biker was before step    
toFollow 	is there a pack to join (yes=1)		
rank 		position in the race			goes to zero when complete race
							(modelling quirk)

MODEL DETAILS: Global Variables
-------------------------------
ticks 		time step counter			initialized to 0
credFollow 	energy credit for following (to est)	set at 2
lead 		fraction of credFollow given to leader	set at 8 (NEEN TO CHANGE!)
nt 		# of bikers with tortoise strategy	8
nh 		# of bikers with hare strategy		8
nf 		# of bikers with free-rider strategy	8
numFinish 	counter for bikers 			program stops when = nt+nh+nf

MODEL DETAILS: Biker Strategies
-------------------------------
Tortoise: Maintain average speed; don’t push anything! Travel as close to eave as possible, moving back if spaces are full with no preference for joining packs or riding alone.  If the finish line is in sight, use all of est to bolt ahead in the endgame. NOTE: As a reward for riding slow and steady throughout the race, the tortoise is able to see the finish line further than their visibility, allowing them to bolt once the finish line is within 4*vf (4 * their visibility).

Hare:Give it all you have got; full exhaustion!  Travel as close to eave+est as possible, moving back if spaces are full with no preference for joining packs or riding alone

Free-Rider: Take the easy way (ride in the back of packs and bolt ahead when possible)
Join the pack that is as far ahead as possible, but no further than min(biker’s visibility, eave+est).  If no pack is available, move eave and save stored energy.

MODEL DETAILS: Action
----------------------
Agent Creation: Agents are created by strategy type: Tortoise; Hare; Free-rider.  It is possible to modify the order of breed creation to investigate any bias created.

Schedule: 
1. Move with asynchronous updating, move sequence = creation rank
2. Update energy stock, est
3. Verify if race is completed (if so, assign rank)
4. Stopping criteria: if biker crosses the finish line, they die and numFinish is incremented by one.  The model should stop running when all agents have crossed the finish line.

NOTE: The sequencing assumption is poor.  Ideally, initial starting should be either random or ranked by eave.  Subsequent update should be ranked by position (high rank agents move first).  We are not sure how to alter order of update on NetLogo.  From the FAQ on the NetLogo documentation page (http://ccl.northwestern.edu/netlogo/docs/):
	
	QUESTION: How does NetLogo decide when to switch from agent to agent when 		running code?

	If you ask turtles, or ask a whole breed, the turtles are scheduled for 		execution in ascending order by ID number. If you ask patches, the patches are 		scheduled for execution by row: left to right within each row, and starting 		with the top row.

	If you ask a different agentset besides the set of all turtles or patches or a 		breed, then the execution order will vary according to how the agentset was 		constructed. The execution order is chosen deterministically and reproducibly, 		though, and will remain the same if you ask the same agentset multiple times.

	In a future version of NetLogo, we plan to add an option for randomized 		scheduling.

	Once scheduled, an agent's "turn" ends only once it performs an action that 		affects the state of the world, such as moving, or creating a turtle, or 		changing the value of a global, turtle, or patch variable. (Setting a local 		variable doesn't count.)

	NetLogo's scheduling mechanism is completely deterministic. Given the same code 	and the same initial conditions, the same thing will always happen, if you are 		using the same version of NetLogo.

	In general, we suggest you write your NetLogo code so that it does not depend 		on a particular scheduling mechanism. We make no guarantees that the scheduling 	algorithm will remain the same in future versions. 

MODEL DETAILS: Caveat
---------------------
We looked at NetLogo for the very first time ever two days ago.  Though things seem to be working as they should, it is very possible that there are errors in this program.  

OBSERVATIONS ON THE MODEL
-------------------------
1. The model is conceptualized such that riding in a pack confers some benefit (accumulation of energy in est).  Howver, it comes at some cost; breaking out of a pack requires enough energy (stored or possessed through ability) to overcome all adjacent riders.
2. In general, passing requires enough saved energy to pass all riders in front, which is reasonable given bikers incentive to stop others from passing.
3. Bikers forward visibility (vf) varies, and is fully correlated with their ability.  THis is assumption is justified by the facts that: a/ the faster a biker is riding (controlled by eave, or ability), the further ahead they should be able to see; and, b/ riders with more ability (higher eave) are often better riders and are more aware of their surroundings. 

OBSERVATIONS ON RESULTS
-----------------------
NEED TO WRITE.

POSSIBLE DEVELOPMENTS AND ALTERNATIVES
--------------------------------------
Strategies: Add more/different strategies, including strategies that are based on perceptions of others (characteristics and/or strategy) and cooperation.  Consider implementing an El Farol type of approach – endogenous strategy choice.

Sequentiality: Order of agent moves could be random, ranked by position, ranked by average or available energy…

Topologies: Alternative topologies like CA, continuous Cartesian space, realistic space (terrain type, etc.).

Physics: Realistic motion, overcoming, etc.

THINGS TO TRY AND TO INVESTIGATE
--------------------------------
1. Does the outcome vary depending on number of bikers; composition of biker strategy; length of race; credit given to followers and leaders?  
2. What happens if ability is correlated with strategy chosen?
3. Can strategy choice overcome deficiency in fitness?  Is there an optimal choice for a biker with a specified ability (and does the optimal choice vary by ability level)?  

SOCIAL SCIENCE APPLICATIONS
---------------------------
The key questions that can be investigated in this model are:
1. In a game with individual prizes but strong interaction effects, how does an individual find an intertemporal balance of cooperation and competition?  
2. How to cooperate to exclude competitor group(s) from having a chance to win?
3. When to defect from the group and compete for individual victory?

Applications:
1. General group formation / cooperation mechanisms (tags).
2. Perception mechanisms – how to evaluate perceived threat level of opponent and select cooperation group?
3. Applied example – workplace teams with hierarchical remuneration systems.


@#$#@#$#@
default
true
0
Polygon -7566196 true true 150 5 40 250 150 205 260 250
Rectangle -16777216 true false 102 80 190 167
Rectangle -16777216 true false 104 167 156 195
Rectangle -16777216 true false 157 168 187 191

bike
false
0
Circle -7566196 true true 155 20 63
Rectangle -7566196 true true 158 79 217 164
Polygon -7566196 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7566196 true true 216 83 267 123 248 143 215 107
Polygon -7566196 true true 167 163 145 234 183 234 183 163
Polygon -7566196 true true 195 163 195 233 227 233 206 159
Circle -7566196 true true 134 173 69
Circle -7566196 true true 187 179 60
Circle -7566196 true true 198 177 42

car
true
15
Circle -1 false true 185 55 60
Circle -1 false true 183 186 61
Polygon -1 true true 214 52 214 22 182 26 162 38 144 74 138 102 100 120 99 161 102 201 118 246 152 267 190 275 210 251 187 240 178 200 204 182 215 181 214 118 193 112 182 98 181 72 198 52

goof
true
0
Rectangle -7566196 true true 96 64 120 118
Rectangle -7566196 true true 70 117 208 136
Rectangle -7566196 true true 89 138 94 161
Rectangle -7566196 true true 187 142 191 162

house
true
14
Rectangle -7566196 true false 33 90 258 243
Polygon -7566196 true false 13 89 151 1 288 89
Rectangle -7566196 true false 120 158 167 242
Rectangle -16777216 true true 118 154 170 241
Rectangle -16777216 true true 181 114 242 148
Rectangle -16777216 true true 126 180 152 184
Rectangle -7566196 true false 195 17 230 55

person
false
0
Circle -7566196 true true 155 20 63
Rectangle -7566196 true true 158 79 217 164
Polygon -7566196 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7566196 true true 216 83 267 123 248 143 215 107
Polygon -7566196 true true 167 163 145 234 183 234 183 163
Polygon -7566196 true true 195 163 195 233 227 233 206 159

stop sign
true
0
Polygon -7566196 true true 78 119 135 75 197 75 244 121 245 181 197 224 136 224 88 183 89 112 90 112 136 75 137 77

street light
true
0
Rectangle -7566196 true true 61 79 75 270
Rectangle -7566196 true true 62 78 134 104
Line -7566196 true 99 106 80 128
Line -7566196 true 101 108 100 128
Line -7566196 true 108 108 117 126
Line -7566196 true 121 108 136 132
Line -7566196 true 118 111 125 126

truck-right
false
0
Polygon -7566196 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8716033 true false 210 210 195 225 180 210
Polygon -8716033 true false 120 210 105 225 90 210

@#$#@#$#@
NetLogo 2.0.1
@#$#@#$#@
setup
repeat 150 [ drive ]
@#$#@#$#@
@#$#@#$#@
