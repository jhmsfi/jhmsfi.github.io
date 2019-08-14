turtles-own
[
  investing?           ;; if true, the turtle is infectious
  withdrawn?           ;; if true, the turtle can't be infected
  threshold            ;; number of other agents that invenst to become an invester
]

globals[
  fund-size            ;; amount of money left in the pot
  max-fund-size
  investing-agents
]

to setup
  clear-all
  setup-nodes
  setup-network
  ask links [ set color white ]
  update-plot
end

to setup-nodes
  set-default-shape turtles "circle"
  crt number-of-nodes
  [
    setxy (random-xcor * 0.95) (random-ycor * 0.95)
    become-naive
    set threshold random threshold-max
  ]
  ask turtle 0 [invest]
end

to add-edge
  let node1 one-of turtles
  let node2 one-of turtles
  ask node1 [
    ifelse link-neighbor? node2 or node1 = node2
      [ add-edge ]
      [ create-link-with node2 ]
    ]       
end


to setup-network
  
  if network-structure = "roughly uniform" [
    let index 0  ;;creates a time-out counter so it doesn't hang on weird configurations
    while [ any? turtles with [count my-links < (node-degree)] and index < ((node-degree + 2 ) * number-of-nodes)] [
        set index index + 1
        let open-nodes turtles with [count my-links < node-degree]
        ask one-of open-nodes [
          let other-node one-of open-nodes with [who != [who] of myself]
          if other-node != nobody 
            [ if not member? other-node link-neighbors
              [ create-link-with other-node [set color 4] ]
            ]  
        ]
    ]
  ]
  
  if network-structure = "random" [
    repeat (number-of-nodes * average-node-degree) [
      add-edge
    ]
  ]
  
  if network-structure = "power law" [
    ask turtle 1 [create-link-with turtle 0]
    foreach sort turtles  [
      ask ? [
        attach-node find-partner
      ]
    ]
  ]  
  
  if network-structure = "spatial density" [
    let num-links (average-node-degree * number-of-nodes) / 2
    while [count links < num-links ]
    [
      ask one-of turtles
      [
        let choice (min-one-of (other turtles with [not link-neighbor? myself])
                     [distance myself])
        if choice != nobody [ create-link-with choice ]
      ]
    ]
  ]
  
  if layout? [layout]
end

to go
  if all? turtles [not investing?]
    [ stop ]
  spread-investment
  set fund-size fund-size - (count turtles with [investing?] * interest-rate * investment-amount)
  do-withdraw-checks
  set investing-agents count turtles with [investing?]
  tick
  update-plot
  if layout? [layout]
  if fund-size > max-fund-size [set max-fund-size fund-size]
  if fund-size < 0 [
    stop    
  ]
end

to invest  ;; turtle procedure
  set investing? true
  set withdrawn? false
  set color red
  set fund-size fund-size + investment-amount
end

to become-naive  ;; turtle procedure
  set investing? false
  set withdrawn? false
  set color green
end

to withdraw  ;; turtle procedure
  set investing? false
  set withdrawn? true
  set color gray
  ask my-links [ set color gray - 2 ]
  set fund-size fund-size - investment-amount
end

to spread-investment
  ask turtles with [not investing? and not withdrawn?]
    [ if count link-neighbors with [investing?] > threshold
       [ invest ] ]
end

to do-withdraw-checks
  ask turtles with [investing?]
  [ if random 100 < withdrawl-chance or (count link-neighbors with [withdrawn? = true]) > withdraw-threshold
        [ withdraw ]
  ]
end


to attach-node [old-node]
  
    if old-node != nobody
      [ create-link-with old-node [ set color green ]
        move-to old-node
        fd 8
      ]
  
end

to-report find-partner
  let total random-float sum [count link-neighbors] of turtles
  let partner nobody
  ask other turtles
  [
    let nc count link-neighbors
    ;; if there's no winner yet...
    if partner = nobody
    [
      ifelse nc > total
        [ set partner self ]
        [ set total total - nc ]
    ]
  ]
  report partner
end


;;------------------------------- Plotting ----------------------------
to update-plot
  set-current-plot "Network Status"
  set-current-plot-pen "naive"
  plot (count turtles with [not investing? and not withdrawn?]) / (count turtles) * 100
  set-current-plot-pen "investing"
  plot (count turtles with [investing?]) / (count turtles) * 100
  set-current-plot-pen "withdrawn"
  plot (count turtles with [withdrawn?]) / (count turtles) * 100
  
  set-current-plot "Fund Size"
  set-current-plot-pen "fund-amount"
  plot fund-size
end


;;------------------------------- Layout ----------------------------
to layout
  ;; the number 10 here is arbitrary; more repetitions slows down the
  ;; model, but too few gives poor layouts
  repeat 10 [
    do-layout
    display  ;; so we get smooth animation
  ]
end

to do-layout
  ;;layout-radial turtles links turtle 0
  layout-spring (turtles with [any? link-neighbors]) links 0.4 6 1
  ;;ask turtle 0 [setxy 0 max-pxcor]
  ;;__layout-magspring (turtles with [any? link-neighbors]) links .7 3 1 .50 5 false
end
@#$#@#$#@
GRAPHICS-WINDOW
529
10
966
468
30
30
7.0
1
10
1
1
1
0
0
0
1
-30
30
-30
30
1
1
1
ticks

CC-WINDOW
5
514
975
609
Command Center
0

SLIDER
5
467
210
500
withdrawl-chance
withdrawl-chance
0.0
100
1
1
1
%
HORIZONTAL

SLIDER
5
432
210
465
naive-chance
naive-chance
0.0
10.0
0
0.1
1
%
HORIZONTAL

BUTTON
9
10
76
43
NIL
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
143
10
205
43
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

PLOT
270
328
525
492
Network Status
time
% of nodes
0.0
100.0
0.0
100.0
true
true
PENS
"naive" 1.0 0 -10899396 true
"investing" 1.0 0 -2674135 true
"withdrawn" 1.0 0 -7500403 true

SLIDER
9
45
205
78
number-of-nodes
number-of-nodes
10
300
300
5
1
NIL
HORIZONTAL

SLIDER
9
142
205
175
average-node-degree
average-node-degree
1
10
3
1
1
NIL
HORIZONTAL

BUTTON
78
10
141
43
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

SWITCH
228
10
331
43
layout?
layout?
1
1
-1000

CHOOSER
228
46
366
91
network-structure
network-structure
"roughly uniform" "random" "power law" "spatial density"
3

SLIDER
9
93
205
126
node-degree
node-degree
0
10
3
1
1
NIL
HORIZONTAL

TEXTBOX
14
80
164
98
uniform network structure
11
0.0
1

TEXTBOX
14
129
216
147
random and spatial graph structure
11
0.0
1

SLIDER
5
326
209
359
threshold-max
threshold-max
1
4
2
1
1
NIL
HORIZONTAL

SLIDER
5
291
209
324
interest-rate
interest-rate
0
.2
0.05
.01
1
NIL
HORIZONTAL

SLIDER
5
361
209
394
withdraw-threshold
withdraw-threshold
0
4
4
1
1
NIL
HORIZONTAL

SLIDER
11
193
205
226
investment-amount
investment-amount
1000
10000
5000
1
1
NIL
HORIZONTAL

PLOT
270
133
525
323
Fund Size
time
funds
0.0
100.0
0.0
10.0
true
false
PENS
"fund-amount" 1.0 0 -16777216 true

BUTTON
333
10
399
43
NIL
layout
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

@#$#@#$#@
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
NetLogo 4.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="PionziExperiment" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>max-fund-size</metric>
    <metric>ticks</metric>
    <metric>investing-agents</metric>
    <enumeratedValueSet variable="withdrawl-chance">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold-max">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="naive-chance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="node-degree">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="withdraw-threshold">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investment-amount">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-structure">
      <value value="&quot;spatial density&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;power law&quot;"/>
      <value value="&quot;roughly uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="layout?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interest-rate">
      <value value="0.05"/>
      <value value="0.15"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
