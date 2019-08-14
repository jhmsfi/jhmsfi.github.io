globals 
[ 
  ;; radius ;; how far the cars can see
  ;; unpark_probability ;; how likely cars are to unpark
  ticks  ;; what round are we?
  number_parked
  total_driving_time
  total_distance
  total_utility
]

turtles-own 
[
  state ;; "leaving" for leaving, "parking" for parking, "moving" for moving
  threshold ;; threshold for whether we take a risky space
  time_driving ;; how long the agent has been driving
  regret ;; how much you regret your choice--used for adaptation
  walking_cost ;; cost of walking one space further
  driving_time_cost ;; cost of driving one period longer
]

to setup
  ca
  set ticks 0
  set total_driving_time 0
  set total_utility 0
  set number_parked 0
  set total_distance 0
  set-current-plot "avg driving time"
  plot 0 ;; avoid divide by 0
  set-current-plot "avg distance to mall"
  plot 0
  set-current-plot "avg utility level"
  plot 0
  ask patches [ setup-road ]
  ask patches [ setup-parking ]
  setup-cars
end

to setup-road
   if ( pycor = 0 ) [ set pcolor white ]
end

to setup-parking
   if ( pycor = 1 ) [ 
     set pcolor yellow 
   ]
   
end

to setup-cars
  if (number_of_cars > world-width )
  [
    user-message "There are too many cars for the amount of road.  Please decrease the NUMBER-OF-CARS slider to below " + (world-width + 1) + " and press the SETUP button again.  The setup has stopped."
    stop
  ]
  set-default-shape turtles "car"
  cct number_of_cars [
    set color red
    set state "moving"
    set threshold default_threshold
    set regret 0
    set walking_cost  2
    set driving_time_cost 1
    setxy random-xcor 0  ;; place them randomly on the line
    set heading 90 ;; they go right
    ;; if we want, randomly park some cars
    separate-cars
  ]
end

to separate-cars
  if any? other-turtles-here
  [ 
    ifelse (can-move? 1)
    [
      fd 1
    ]
    [
      home
    ]  
    separate-cars 
  ]
end

to park
  set state "parking"
  set heading 0
  fd 1  
  set heading 90
  record-data
  
end

to unpark
  set heading 180
  ifelse (count turtles-at 0 -1) > 0
  [   
    fd 0 ;; don't move because there would be a collision
  ]
  [
    fd 1 
  ]
  set heading 90
end

to go
  ask turtles with [state = "moving"] [set time_driving (time_driving + 1)]
  ask turtles with [(pycor = 1) and (state = "parking")] [decide-to-leave]
  ask turtles with [(pycor = 0) and (state = "moving")] [decide-to-move]
  ask turtles [ move ]
  ifelse (number_parked = 0)
  [
    set-current-plot "avg driving time"
    plot 0
    set-current-plot "avg distance to mall"
    plot 0
    set-current-plot "avg utility level"
    plot 0
  ]
  [
    set-current-plot "avg driving time"
    plot total_driving_time / number_parked
    set-current-plot "avg distance to mall"
    plot total_distance / number_parked
    set-current-plot "avg utility level"
    plot total_utility / number_parked
  ]
  set ticks (ticks + 1)
end

to decide-to-leave
  if (random 100 < unpark_probability)
  [
    set state "leaving" ;; mark intention to leave
    set color blue
  ]
end



to decide-to-move
  ifelse (count turtles-at 0 1) > 0 ;; the next-door space is full
  [
    ;; we have to go, handled by "move"
    stop
  ]
  [ ;; the next-door space is empty
    let s 0 ;;talley of empty spaces
    let x 0 ;;talley of cars
    let r 1 ;;index--count up from current position
    let searchrad radius
    if (radius > (max-pxcor - pxcor))
    [
      set searchrad (max-pxcor - pxcor)
    ]
    while [r <= searchrad]
    [
      if (count turtles-at r 1 = 0) [set s (s + 1)]
      if (count turtles-at r 0 = 1) [set x (x + 1)]
      ifelse (s > x) ;; the car is guarenteed a closer spot
      [
        ;; we're going to go, handled by "move"
        stop
      ]    
      [
      set r (r + 1)
      ]     
    ]
    ifelse (x != 0)
    [
      ifelse ( (s / x) * ((max-pxcor - pxcor) / max-pxcor) > threshold)
      [   
        ;; we're going to go, handled by "move"
        stop
      ]  
      [
        park
      ]
    ]
    [
      park
    ]
  ]
end

to move
  ifelse ((pycor = 1) and (state = "leaving")) [ unpark ]
  [
    if (pycor = 0) 
    [ 
      ifelse (count turtles-at 1 0) > 0
      [
        fd 0 ;; don't move because there would be a collision
      ]
      [
        ifelse can-move? 1
        [
          fd 1
        ]
        [
          if (state = "leaving")
          [
            set state "moving"
            set color red
            set time_driving 0
          ]
          home
        ]
      ]
    ]
  ]
end

to-report curr-round
  report ticks
end

to record-data
  set total_driving_time (total_driving_time +  time_driving)
  set number_parked (number_parked + 1)
  set total_distance (total_distance + (max-pxcor - xcor))
  let disappointments 0 ;; number of empty spaces you see walking to the mall--not stored
  let i (xcor + 1)
  while [ i < max-pxcor ] 
  [
    if (count turtles-at i 0 = 1) 
    [
    set disappointments (disappointments + 1)
    ]
    set i (i + 1)
  ]
  set regret (walking_cost * disappointments)
  let utility (walking_cost * (max-pxcor - xcor) + driving_time_cost * time_driving + regret)
  set total_utility (total_utility + utility)
end

to-report avg_dtime
  ifelse (number_parked = 0)
  [
    report 0
  ]
  [
    report total_driving_time / number_parked
  ]
end

to-report avg_distance
  ifelse (number_parked = 0)
  [
    report 0
  ]
  [
  report total_distance / number_parked
  ]
end

to-report avg_utility
  ifelse (number_parked = 0)
  [
    report 0
  ]
  [
    report total_utility / number_parked
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
1
325
767
464
-1
-1
36.0
1
12
1
1
1
0
0
0
1
0
20
0
2

CC-WINDOW
5
478
776
573
Command Center
0

SLIDER
107
79
279
112
number_of_cars
number_of_cars
0
20
20
1
1
NIL

SLIDER
107
113
279
146
radius
radius
0
20
20
1
1
NIL

BUTTON
5
10
77
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL

BUTTON
5
82
68
115
go
go
T
1
T
OBSERVER
NIL
NIL

SLIDER
107
10
301
43
unpark_probability
unpark_probability
0
100
3
1
1
NIL

SLIDER
107
45
296
78
default_threshold
default_threshold
0
1
1.0
0.05
1
NIL

MONITOR
5
123
62
172
round
curr-round
3
1

BUTTON
5
46
68
79
step
go
NIL
1
T
OBSERVER
NIL
NIL

PLOT
320
11
520
161
avg driving time
round
driving time
0.0
10.0
0.0
10.0
true
false

PLOT
538
11
738
161
avg distance to mall
round
distance
0.0
10.0
0.0
10.0
true
false

PLOT
426
169
626
319
avg utility level
round
utlity level
0.0
10.0
0.0
10.0
true
false

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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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
NetLogo 3.1.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryTick="false">
    <setup>setup
</setup>
    <go>go</go>
    <timeLimit ticks="5000"/>
    <metric>avg_distance</metric>
    <metric>avg_utility</metric>
    <metric>avg_dtime</metric>
    <enumeratedValueSet variable="unpark_probability">
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number_of_cars" first="1" step="1" last="20"/>
    <steppedValueSet variable="radius" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="default_threshold">
      <value value="0.6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="1" runMetricsEveryTick="false">
    <setup>setup
</setup>
    <go>go</go>
    <timeLimit ticks="5000"/>
    <metric>avg_distance</metric>
    <metric>avg_utility</metric>
    <metric>avg_dtime</metric>
    <enumeratedValueSet variable="unpark_probability">
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number_of_cars" first="1" step="1" last="20"/>
    <enumeratedValueSet variable="radius">
      <value value="20"/>
    </enumeratedValueSet>
    <steppedValueSet variable="default_threshold" first="0" step="0.1" last="1"/>
  </experiment>
</experiments>
@#$#@#$#@
