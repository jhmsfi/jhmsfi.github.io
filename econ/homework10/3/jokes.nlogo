
extensions [array]
globals [ feature-to-show]
breed [ agents agent ]
breed [ jokes joke ]
undirected-link-breed [ contacts contact ]
undirected-link-breed [ my-jokes my-joke ]
agents-own [ agent-features alter-score ]
jokes-own [ joke-features funniness joke-utility joke-selection-prob ] 
contacts-own [ strength contact-utility contact-selection-prob ]
my-jokes-own [ age already-told-to ]

to setup
  set feature-to-show 0
  setup-agents 
  setup-network
  setup-jokes
  update-display
end  

to setup-agents
  clear-all
  create-agents population
  ask agents  [ 
    set agent-features array:from-list n-values features [random traits]
    set shape "person"
    set size 2
    set color (5 + 10 * array:item agent-features 0) 
    setxy random-xcor random-ycor
  ]
end

to setup-network
  ask agents [
     let ego self
     ask other agents [
        let alter self
        create-contact-with ego [
          set strength get-strength ego alter
          set label (precision strength 2 ) / ((count turtles) - 1)
          
        ]
     ]
  ]
  ;;ask contacts [ set color black ]
  ask jokes [ hide-turtle  ]
end

to setup-jokes
  create-jokes initial-jokes
  ask jokes [
    create-my-joke-with one-of agents [ set age random 80 ]
  ]
  ask jokes [
     set joke-features array:from-list n-values features [-1]
     let joke-owner one-of my-joke-neighbors
     foreach n-values features [?] [
       let option get-initial-joke-adoption 
       if (option = 1) [
           array:set joke-features ? ([array:item agent-features ?] of joke-owner) 
       ]
       if (option = 2) [
           array:set joke-features ? abs( 1 - [array:item agent-features ?] of joke-owner) 
       ]
     ]
     set color (8 + 10 * array:item joke-features 0) 
  ]
end


to-report get-initial-joke-adoption
  let ran random-float 1
  if ran < adopt-owner-feature [ report 1 ]
  if ran < adopt-owner-feature + adopt-not-owner-feature [ report 2]
  report 3 
end

to-report get-strength [ agent-one agent-two]
  ifelse strength-similarity [
     let dissimilarity 1
     foreach n-values features [?] [ 
       let score-one 0
       let score-two 0
       ask agent-one [ set score-one array:item agent-features ? ] 
       ask agent-two [ set score-two array:item agent-features ? ] 
       set dissimilarity (dissimilarity + abs (score-one  - score-two))    
     ]
     report 1 / dissimilarity       
  ]
  [ report 1 ]
end

to-report get-joke [ alter ]
  ask my-joke-neighbors [
    set joke-utility exp(McFadden-b2 * (joke-match-score  self alter))
    
  ]
  let denominator sum [joke-utility] of my-joke-neighbors
  let ran random-float denominator
  let score 0
  ask my-joke-neighbors [
    set joke-selection-prob joke-utility / denominator
  ]
  
  foreach sort my-joke-neighbors [
    set score (score + [joke-utility] of ? )
    if ran < score [
      report ?
    ]
  ]
end

to update-joke-age 
  ask my-jokes [ set age age + 1 ]
  ask my-jokes with [ age > joke-lifespan ] [ die ]
  ask jokes with [(count my-joke-neighbors) = 0 ][ die ]
end
  
to-report joke-match-score [ one-joke one-alter ]
  let score 0
  ifelse (boolean-joke-fit = false) [
      foreach n-values features [?] [
        let agent-feature -2
        let joke-feature -2
        ask one-alter [ set agent-feature array:item agent-features ? ]
        ask one-joke [ set joke-feature array:item joke-features ? ]
        if agent-feature = joke-feature or joke-feature = -1 [ set score score + 1]
      ]
      report score
  ]
  [
      foreach n-values features [?] [
        let agent-feature -2
        let joke-feature -2
        ask one-alter [ set agent-feature array:item agent-features ? ]
        ask one-joke [ set joke-feature array:item joke-features ? ]
        if (agent-feature = 1 and joke-feature = 0)  or (joke-feature = 1 and agent-feature = 0) [ report 0]
      ]
      report 1    
  ]
  
  

end

to-report get-alter
  ask my-contacts [
     set contact-utility exp(McFadden-b1 * strength)  
  ]  
  let denominator sum [contact-utility] of my-contacts
  let ran random-float denominator
  let score 0
  ask my-contacts [
    set contact-selection-prob contact-utility / denominator
  ]
  
  foreach sort my-contacts [
    set score (score + [contact-utility] of ?)
    if ran < score [
       report ?
    ]
  ]
end 

to-report mean-joke-number
   report mean [count my-joke-neighbors] of agents 
end

to show-next-feature
  set feature-to-show feature-to-show + 1
  if feature-to-show = features [ set feature-to-show 0 ]
  ask agents [ set color (5 + 10 * array:item agent-features feature-to-show)]
  ask jokes [ set color (8 + 10 * array:item joke-features feature-to-show) ]
end  

to update-display
  ask agents [ set color (5 + 10 * array:item agent-features feature-to-show)]
  ask jokes [ set color (8 + 10 * array:item joke-features feature-to-show) ]
  repeat 10 [ layout-tutte jokes my-jokes 12 ]
  set-current-plot "number-of-jokes"
  plot count jokes
  set-current-plot "mean-joke-number"
  plot  mean-joke-number
end

to go
   update-display
   let joketellers count agents with [(count my-joke-neighbors) > 0]
   if joketellers > 10 [ set joketellers 10 ]
   if population < 10 and joketellers > population [ set joketellers population ]
   let joke-teller n-of (random joketellers) (agents with [(count my-joke-neighbors) > 0]) 
   ;;let joke-teller one-of agents with [(count my-joke-neighbors) > 0]
   ;;watch joke-teller
   ask joke-teller [
 
    let me self
    let joke-link get-alter
    let temp nobody
    ask joke-link [ set temp both-ends]
    let joke-receiver one-of temp with [who != [who] of me]
    ask joke-receiver [ set color yellow ]
    let joke get-joke joke-receiver
    ask joke-receiver [ 
      if (not (my-joke-neighbor? joke)) [
        create-my-joke-with joke [ 
          set age 0
          
        ]
      ]
    ] 
  ] 
  update-joke-age
  tick

  
end



@#$#@#$#@
GRAPHICS-WINDOW
210
10
649
470
-1
-1
13.0
1
10
1
1
1
0
0
0
1
0
32
0
32
0
0
1
ticks

SLIDER
27
172
199
205
features
features
1
10
5
1
1
NIL
HORIZONTAL

SLIDER
27
213
199
246
traits
traits
1
2
2
1
1
NIL
HORIZONTAL

BUTTON
32
37
95
70
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
27
253
199
286
initial-jokes
initial-jokes
1
1000
5
1
1
NIL
HORIZONTAL

SLIDER
28
127
200
160
population
population
2
1000
5
1
1
NIL
HORIZONTAL

BUTTON
99
37
162
70
NIL
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
31
73
160
108
NIL
 show-next-feature 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SWITCH
535
497
639
530
hist-on
hist-on
0
1
-1000

SWITCH
383
538
533
571
strength-similarity
strength-similarity
0
1
-1000

SLIDER
20
462
196
495
adopt-owner-feature
adopt-owner-feature
0
1
1
.01
1
NIL
HORIZONTAL

SLIDER
21
498
196
531
adopt-not-owner-feature
adopt-not-owner-feature
0
1
0
.01
1
NIL
HORIZONTAL

SLIDER
23
326
195
359
McFadden-b1
McFadden-b1
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
20
393
193
426
McFadden-b2
McFadden-b2
0
100
20
1
1
NIL
HORIZONTAL

SLIDER
203
498
376
531
joke-lifespan
joke-lifespan
0
1000
160
1
1
NIL
HORIZONTAL

MONITOR
23
538
128
583
NIL
feature-to-show
17
1
11

PLOT
675
99
877
250
number-of-jokes
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 0 -16777216 true

MONITOR
884
100
962
145
NIL
count jokes
17
1
11

SWITCH
386
497
531
530
boolean-joke-fit
boolean-joke-fit
1
1
-1000

MONITOR
887
285
963
330
mean jokes
 mean [count my-joke-neighbors] of agents 
17
1
11

PLOT
678
285
879
435
mean-joke-number
NIL
NIL
0.0
10.0
0.0
3.0
true
false
PENS
"default" 1.0 0 -16777216 true

TEXTBOX
27
298
177
326
Non-randomness of alter selection
11
0.0
1

TEXTBOX
25
364
175
392
Non-randomness of joke selection
11
0.0
1

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Axelrod" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>largest-region</metric>
    <metric>event-num</metric>
    <enumeratedValueSet variable="traits">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="features">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="update-interval">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighborhood">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hist-on">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-mutation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="smallw-k">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Network">
      <value value="&quot;lattice&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fix-random-seed">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-threshold">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Influence">
      <value value="&quot;Axelrod (dyadic)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="smallw-p">
      <value value="0.124"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-on">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>count jokes</metric>
    <enumeratedValueSet variable="adopt-owner-feature">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hist-on">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="McFadden-b1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adopt-not-owner-feature">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initital-genericness-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="joke-lifespan">
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="features">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-jokes">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="boolean-joke-fit">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strength-similarity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="McFadden-b2">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="traits">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count jokes</metric>
    <enumeratedValueSet variable="adopt-owner-feature">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hist-on">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="McFadden-b1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adopt-not-owner-feature">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initital-genericness-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="joke-lifespan">
      <value value="100"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="features">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-jokes">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="boolean-joke-fit">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strength-similarity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="McFadden-b2">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="traits">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count jokes</metric>
    <metric>mean-joke-number</metric>
    <enumeratedValueSet variable="adopt-owner-feature">
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hist-on">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="McFadden-b1">
      <value value="0"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adopt-not-owner-feature">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initital-genericness-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="joke-lifespan">
      <value value="80"/>
      <value value="160"/>
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="features">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-jokes">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="boolean-joke-fit">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strength-similarity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="McFadden-b2">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="traits">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count jokes</metric>
    <metric>mean-joke-number</metric>
    <enumeratedValueSet variable="adopt-owner-feature">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hist-on">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="McFadden-b1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adopt-not-owner-feature">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initital-genericness-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="joke-lifespan">
      <value value="160"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="features">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-jokes">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="boolean-joke-fit">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strength-similarity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="McFadden-b2">
      <value value="0"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="traits">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
