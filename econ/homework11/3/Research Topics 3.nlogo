turtles-own [influence working a b c d]

to setup
  clear-all
  create-turtles initial-academics
  ask turtles [
    set influence (random 100) / 100
    set a random 100
    set b random 100
    set c random 100
    set d random 100
    set working 0
    set color white
    set size 4
    set shape "person graduate"
    setxy random-xcor random-ycor
    ]
  update-plot
end

to go
  move-turtles
  ask turtles [interact]
  ask turtles [project]
  ask turtles [ if working > 0 [set working working - 1]]
  tick
  update-plot
end

to move-turtles
  ask turtles [
    right random 360
    forward 1
  ]
end

to interact
  if working = 0 [
  set color white  
  set a a - decay
  set b b - decay
  set c c - decay
  set d d - decay
  if a < 0 [set a 0]
  if b < 0 [set b 0]
  if c < 0 [set c 0]
  if d < 0 [set d 0]    
  let discussant one-of turtles-here
  if discussant != nobody
  [let tempa [a] of discussant
    let tempb [b] of discussant
    let tempc [c] of discussant
    let tempd [d] of discussant
    let inf [influence] of discussant
  set a a + tempa * inf
  set b b + tempb * inf
  set c c + tempc * inf
  set d d + tempd * inf
   ]]
end

to project
  if a > threshold [
  set working random worktime
  set color blue
  set a random experienced
  set b random inexperienced
  set c random inexperienced
  set d random inexperienced
  ]

if b > threshold [
  set working random worktime
  set color green
  set a random inexperienced
  set b random experienced
  set c random inexperienced
  set d random inexperienced
  ]

if c > threshold [
  set working random worktime
  set color yellow
  set a random inexperienced
  set b random inexperienced
  set c random experienced
  set d random inexperienced
  ]

if d > threshold [
  set working random worktime
  set color red
  set a random inexperienced
  set b random inexperienced
  set c random inexperienced
  set d random experienced
  ]

end

to update-plot
  set-current-plot "Projects"
  set-current-plot-pen "nw"
  plot count turtles with [color = white]
  set-current-plot-pen "blue"
  plot count turtles with [color = blue]
  set-current-plot-pen "green"
  plot count turtles with [color = green]
  set-current-plot-pen "yellow"
  plot count turtles with [color = yellow]
  set-current-plot-pen "red"
  plot count turtles with [color = red]
end
@#$#@#$#@
GRAPHICS-WINDOW
372
10
841
500
25
25
9.0
1
14
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks

SLIDER
3
150
216
183
initial-academics
initial-academics
0
250
250
1
1
NIL
HORIZONTAL

SLIDER
7
70
219
103
threshold
threshold
0
150
101
1
1
NIL
HORIZONTAL

BUTTON
8
28
77
61
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
90
28
157
61
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
164
28
227
61
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
6
201
178
234
decay
decay
0
2
1.1
.1
1
NIL
HORIZONTAL

PLOT
9
347
340
553
Projects
time
pop.
0.0
10.0
0.0
30.0
true
true
PENS
"blue" 1.0 0 -13345367 true
"green" 1.0 0 -10899396 true
"yellow" 1.0 0 -1184463 true
"red" 1.0 0 -2674135 true
"nw" 1.0 0 -16777216 true

MONITOR
7
243
97
288
Unemployed
count turtles with [color = white]
17
1
11

MONITOR
110
244
196
289
"A" Blue
count turtles with [color = blue]
17
1
11

MONITOR
206
245
300
290
B "Green"
count turtles with [color = green]
17
1
11

MONITOR
8
296
82
341
C "Yellow"
count turtles with [color = yellow]
17
1
11

MONITOR
90
297
163
342
D "Red"
count turtles with [color = red]
17
1
11

SLIDER
7
108
179
141
experienced
experienced
0
threshold / 2
25
1
1
NIL
HORIZONTAL

SLIDER
181
108
353
141
inexperienced
inexperienced
0
threshold / 2
50
1
1
NIL
HORIZONTAL

SLIDER
192
200
364
233
worktime
worktime
0
50
50
1
1
NIL
HORIZONTAL

@#$#@#$#@
A MODEL OF ACADEMICS CHOOSING RESEARCH TOPICS

MODEL MOTIVATION
------------

In modeling the way that academics choose their research projects, we started by thinking about the ways the academics become interested in different topics.  Primarily, we think, academics become interested in different research projects for two reasons:

- Academics are naturally interested in certain topics more than others.
- Academics interact with other academics, and the academic's discussants have a certain influence over what the academic is interested in. 


For example, a Philosophy professor may be interested in metaphysics and the philosophy of language.  Such an interest is likely to guide the professor's initial choice of research topic (namely, the professor will probably choose to research something in the field of metaphysics.) However, the more interactions this professor has with other academics who study epistemology, the more likely this professor will be to investigate epistemology.  We think of this as a social-influence model for choose research topics.

MODEL ASSUMPTIONS AND IMPLEMENTATION
----------------

In our model, we assume:

- There are a number of academics in the world.

- Academics walk around and get engaged in conversation with other academics.

- When they get involved in conversation, academics are influenced by the research interests of their discussants.  The level of influence depends upon the charisma and prestige of the discussant.

- In order for an academic to start working on a project, his or her interest in that area must exceed some threshold. 

- Agents work a set period of time on a given project. When the project is finished, agents stop working on the project, reset their preferences and
start looking for a new project. 

Furthermore, in addition to our core assumptions, we implemented the assumptions in the following way:

- Charisma and prestige, the property that allows certain academics to be more influential than others, is randomly distributed through academics in the population, and is universal. By universal, we mean that Academic 1 has the same level of influence on Academic 2 as Academic 3, Academic 2 has the same level of influence on 1 as s/he has on 3, and 3 has the same level of influence on 1 as s/he has on 2.  The level of influence any individual academic has on his or her peers lies between 0 and 1.  Thus, academics with an influence level of .5 will transfer .5 of their interests to the people talking to them.

- There are four general research areas that academics can get interested in: A (blue projects), B (green projects), C(yellow projects), and D (red projects).

- If an academic exceeds the threshold of interest to start on two projects at once, we assume that A projects more prestigious (and therefore more desirable) than B projects, which are more prestigious than C projects, which are more prestigious than D projects.  Thus, agents chose lexicographically among possible projects.  For example, if their interest in a project of type A  and a project of type B exceeds the set threshold simultaneously, they start working on an A project rather than working on a B project. 

- Academics start off with a series of interests in these four areas, randomly generated from a uniform distribution between 0 and 100.  When an academic interacts (runs in to) another academic, the first academic copies the interests the second academic has times the influence of the second academic.  

- Once a researcher finishes a project, his or her interests reset to a level determined by the model, with parameters manipulable by the modeler.  The "experienced" parameter indicates the level of interest that the researcher resets to for the type of project he or she has just finished working on.  The "inexperienced" parameter indicates the level of interest that the researcher resets to for the types of project that he or she did not just work on.  Using these levels, the modeler can control the extent to which research is path-dependent: if it is thought that working on a particular type of project makes one much more likely to work on that project again than another type of project, then the "experienced" slider should be set to a much higher level than the "inexperienced" slider.  If, in contrast, one thinks that working on a particular kind of project burns out a researcher, and makes him or her more likely to seek out different sorts of projects in the future, one should set the "inexperienced" slider higher than the "experienced" slider.
	
- Any project, which undertaken, takes a random amount of time from zero ticks until X ticks, where X is a level set by the modeler.  (The default is 50.)	When working on a project, a researcher is able to influence other researchers, but is unable to have his or her own preferences influenced.
	
- Lastly, we introduce a decay parameter, which simply states that, if a researcher's interest in a topic is not stimulated by conversations with other academics, the researcher's interest will wane.  

ILLUSTRATIVE EXAMPLE
-------

Let's run through an example.  Let us say that we set all the parameters in the model at the following levels:

"Threshold" is set to 100.
"Experienced" is set to 50.
"Inexperienced" is set to 25.
"Initial-Academics" is set to 250.
"Decay" is set to 1.1.
"Worktime" is set to 50.

At setup, 250 agents spawn on the model space.  Let's follow one hypothesized agent.  This agent, 42, begins with the following interest levels: 20 for A, 73 for B, 31 for C, and 58 for D.  At the first tick, agent 42 runs into agent 178.  Agent 178's interests, from A to D, are 24, 13, 92, and 67, with an influence level of .1.  Thus, we multiply .1 by all Agent 178's interests and add them to agent 42's interests.  

Agent 42's interests, from A to D, are now 22.4 (20+24*.1), 74.3 (73+13*.1), 40.2 (31+92*.1), and 64.7 (58+67*.1).  At the next tick, 42 runs into nobody, so each of his interests decay by 1.1, leaving him with interest levels of 21.3, 73.2, 39.1, and 63.6.  At the next tick, 42 runs into agent 238.  Agent 238's interests are 56.3, 80.4, 5.9, and 90.5, and agent 238 has an influence level of 1.  Thus, all of Agent 238's interests are added directly to agent 42's.

Agent 42's interests are now 77.6, 153.6, 45.0, and 154.1.  Agent 42 is now sufficiently interested in both projects of type B and D to work on them.  However, Agent 42 can only work on one project at once, and so chooses project B, the more prestigious of the two.  Agent 42 ceases to be searching for a project (and so, ceases to be "unemployed") and begins working on project B, a green project, for 34 ticks (a project length randomly chosen by the model, in the interval 0 to 50).  His interests are set, from A to D, to 25, 50, 25, and 25.  Once Agent 42 has worked on his project for 34 ticks, he begins searching for another project and allowing himself to be influenced by other academics again.

COPYRIGHT NOTICE
----------------
Copyright 2011 Jack Reilly and Johannes Castner. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:
a) this copyright notice is included.
b) this model will not be redistributed for profit without permission. 

CONTACT INFO
--------------

Jack Reilly
jlreilly@ucdavis.edu

Johannes Castner
jac2130@columbia.edu
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person graduate
false
0
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -1 true false 110 5 80
Rectangle -1 true false 127 79 172 94
Polygon -7500403 true true 90 19 150 37 210 19 195 4 105 4
Polygon -7500403 true true 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -16777216 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -16777216 false 195 90 150 135
Line -16777216 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -1 false 208 22 208 57

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Rectangle -1 true true 166 225 195 285
Rectangle -1 true true 62 225 90 285
Rectangle -1 true true 30 75 210 225
Circle -1 true true 135 75 150
Circle -7500403 true false 180 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Rectangle -7500403 true true 195 106 285 150
Rectangle -7500403 true true 195 90 255 105
Polygon -7500403 true true 240 90 217 44 196 90
Polygon -16777216 true false 234 89 218 59 203 89
Rectangle -1 true false 240 93 252 105
Rectangle -16777216 true false 242 96 249 104
Rectangle -16777216 true false 241 125 285 139
Polygon -1 true false 285 125 277 138 269 125
Polygon -1 true false 269 140 262 125 256 140
Rectangle -7500403 true true 45 120 195 195
Rectangle -7500403 true true 45 114 185 120
Rectangle -7500403 true true 165 195 180 270
Rectangle -7500403 true true 60 195 75 270
Polygon -7500403 true true 45 105 15 30 15 75 45 150 60 120

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1.3
@#$#@#$#@
setup
set grass? true
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
