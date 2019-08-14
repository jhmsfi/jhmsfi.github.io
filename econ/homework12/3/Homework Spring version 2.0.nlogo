breed [people person]


globals [
  timestep
  domination   ;; when 2/3 of population is dominated by one political state

]

people-own [
  political-state ;; 1=Pro-active, 2=Pro-inactive, 3=neutral, 4=Against-inactive, 5=Against-active
  x ;;this is in order to let people interact and determine how they will change, if all agents did that they change all at the same time  
]

;;;
;;; SETUP PROCEDURES
;;;

to setup
  ca
  setup-globals
  setup-people

end

to setup-globals
  reset-ticks
  
end



to setup-people
  create-people initial-people 
    ask people[
       
      set political-state 0
      set shape "person"
      set size 5
      ]
      
      ask n-of (initial-people * initial-pro-active) people [
        set political-state 1]
      ask n-of (initial-people * initial-pro-inactive) people with [political-state = 0] [
        set political-state 2]
      ask n-of (initial-people * initial-neutral) people with [political-state = 0] [
        set political-state 3]
      ask n-of (initial-people * initial-against-inactive) people with [political-state = 0] [
        set political-state 4]
      ask n-of (initial-people * initial-against-active) people with [political-state = 0] [
        set political-state 5]  
      
      
      if(position-of-people-on-grid = "random")[
       ask people[
       setxy random-xcor random-ycor]
      ]
      
      if (position-of-people-on-grid  = "perfect-separation")[
      ask people[
        if( political-state = 1)[ 
        set xcor (random-float 50) - 50 
        set ycor (random-float 100) - 50]
        
        if( political-state = 2)[ 
        set xcor (random-float 50) - 50 
        set ycor (random-float 100) - 50]
        
        if( political-state = 4)[ 
        set xcor (random-float 50) 
        set ycor (random-float 100) - 50]
        
        if( political-state = 5)[ 
        set xcor (random-float 50) 
        set ycor (random-float 100) - 50]
        
        if( political-state = 3)[ 
        setxy random-xcor random-ycor  
        ]
      ]
      ]
      
      if (position-of-people-on-grid  = "cluster")[
      ask people[
        if( political-state = 1)[ 
          let division random 2
          ifelse(division = 0) [ 
            set xcor (random-float 50) 
            set ycor (random-float 50) - 50
           ][ 
            set xcor (random-float 50) - 50 
            set ycor (random-float 50) ]
        ]
        
        if( political-state = 2)[ 
        let division random 2
          ifelse(division = 0) [ 
            set xcor (random-float 50) 
            set ycor (random-float 50) - 50
           ][ 
            set xcor (random-float 50) - 50 
            set ycor (random-float 50) ]
        ]
        
        
        if( political-state = 4)[ 
        let division random 2
          ifelse(division = 0) [ 
            set xcor (random-float 50) 
            set ycor (random-float 50)
           ][ 
            set xcor (random-float 50) - 50 
            set ycor (random-float 50) - 50]
        ]
        
        
        if( political-state = 5)[ 
         let division random 2
          ifelse(division = 0) [ 
            set xcor (random-float 50) 
            set ycor (random-float 50)
           ][ 
            set xcor (random-float 50) - 50 
            set ycor (random-float 50) - 50]
        ]
        
        if( political-state = 3)[ 
        setxy random-xcor random-ycor  
        ]
      ]
      ]
      
      assign-color
      
end



;; The political state of the people is refelected by their color
;; green = pro-active
;; lime = pro-inactive
;; yellow = neutral
;; pink = against-inactive 
;; red = against-active

to assign-color  ;; people procedure
  ask people [
  if(political-state = 1) [set color 53]
  if(political-state = 2) [set color 66]
  if(political-state = 3) [set color yellow]
  if(political-state = 4) [set color pink]
  if(political-state = 5) [set color red]
  ]
end

to go
 
 move
 meeting
 change
 assign-color
 update-plot
 tick
 set timestep timestep + 1
 
 ;;check whether one political state dominates
 if((count turtles with [political-state = 1] / initial-people) > (2 / 3))[
   if(domination = 0) [
     set domination timestep]
 ]
 if((count turtles with [political-state = 5] / initial-people) > (2 / 3))[
   if(domination = 0) [
     set domination timestep]]  
if((count turtles with [political-state = 1] / initial-people) = 1 )[
    stop] 
if((count turtles with [political-state = 5] / initial-people) = 1)[
  stop]
end

;;here people move around
to move 
  ask people[
  rt random-float 360
  fd 1
  ]  
end



;; this are the behavioral rules when people bump into each other
to meeting
  ask people [
 
 
  ;;;POLITICAL STATE 1
  
 if(political-state = 1) [
    
   if( any? other people-here with [political-state = 5 ])[ 
     if((count people in-radius 5 with [political-state = 1]) < (count people in-radius 5 with [political-state = 5]))
        [set x 2] 
   ] 
 ]
 
 ;;;POLITICAL STATE 2
 
 if(political-state = 2) [
   if( any? other people-here with [political-state = 1 ])
        [set x 1
   ]
   if( any? other people-here with [political-state = 5 ])
    [set x 3
      ]  
 ]
  
  
 ;;;POLITICAL STATE 3  
  if(political-state = 3) [
   if( any? other people-here with [political-state = 1 ])[
        set x 2]
   
   if( any? other people-here with [political-state = 5 ])
    [ set x 4 
      ]  
 ]
  
 
  ;;;POLITICAL STATE 4 
  if(political-state = 4) [
   if( any? other people-here with [political-state = 1 ])
   [set x 3  
    ]
   
   if( any? other people-here with [political-state = 5 ])
        [set x 5;[set x 4] 
    
    ]
  ]
  
  ;;;POLITICAL STATE 5
  if(political-state = 5) [
   if( any? other people-here with [political-state = 1 ])[ 
     if((count people in-radius 5 with [political-state = 1]) > (count people in-radius 5 with [political-state = 5]))
        [set x 4] 
   ] 
 ]
 
  
  
  ]
end

;;here people update to their new political state
to change
 ask people [
   if(x = 1) [set political-state 1]
   if(x = 2) [set political-state 2]
   if(x = 3) [set political-state 3]
   if(x = 4) [set political-state 4]
   if(x = 5) [set political-state 5] 
 ]
  
end


to update-plot
  set-current-plot "Populations"
  set-current-plot-pen "Pro-active"
  plot count turtles with [political-state = 1] / initial-people 
  set-current-plot-pen "Pro-inactive"
  plot count turtles with [political-state = 2] / initial-people
  set-current-plot-pen "neutral"
  plot count turtles with [political-state = 3] / initial-people
  set-current-plot-pen "Against-inactive"
  plot count turtles with [political-state = 4] / initial-people
  set-current-plot-pen "Against-active"
  plot count turtles with [political-state = 5] / initial-people
end


@#$#@#$#@
GRAPHICS-WINDOW
222
13
737
549
50
50
5.0
1
10
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks

BUTTON
14
10
97
43
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
125
10
208
43
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

SLIDER
13
50
208
83
initial-people
initial-people
50
500
300
1
1
NIL
HORIZONTAL

PLOT
750
13
1181
261
Populations
NIL
people
0.0
0.05
0.0
0.05
true
true
PENS
"Pro-active" 1.0 0 -10899396 true
"Pro-inactive" 1.0 0 -13840069 true
"neutral" 1.0 0 -1184463 true
"Against-inactive" 1.0 0 -2064490 true
"Against-active" 1.0 0 -2674135 true

SLIDER
13
147
210
180
initial-pro-active
initial-pro-active
0
1
0.04
0.01
1
NIL
HORIZONTAL

SLIDER
13
188
210
221
initial-pro-inactive
initial-pro-inactive
0
1
0.4
0.01
1
NIL
HORIZONTAL

SLIDER
13
231
210
264
initial-neutral
initial-neutral
0
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
13
274
210
307
initial-against-inactive
initial-against-inactive
0
1
0.4
0.01
1
NIL
HORIZONTAL

SLIDER
14
318
210
351
initial-against-active
initial-against-active
0
1
0.06
0.01
1
NIL
HORIZONTAL

MONITOR
752
279
998
324
NIL
domination
17
1
11

CHOOSER
12
90
210
135
position-of-people-on-grid
position-of-people-on-grid
"random" "perfect-separation" "cluster"
2

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

person lefty
false
0
Circle -7500403 true true 170 5 80
Polygon -7500403 true true 165 90 180 195 150 285 165 300 195 300 210 225 225 300 255 300 270 285 240 195 255 90
Rectangle -7500403 true true 187 79 232 94
Polygon -7500403 true true 255 90 300 150 285 180 225 105
Polygon -7500403 true true 165 90 120 150 135 180 195 105

person righty
false
0
Circle -7500403 true true 50 5 80
Polygon -7500403 true true 45 90 60 195 30 285 45 300 75 300 90 225 105 300 135 300 150 285 120 195 135 90
Rectangle -7500403 true true 67 79 112 94
Polygon -7500403 true true 135 90 180 150 165 180 105 105
Polygon -7500403 true true 45 90 0 150 15 180 75 105

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
NetLogo 4.1.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>result</metric>
    <enumeratedValueSet variable="random-distribution-people">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-against-active">
      <value value="0.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-against-inactive">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-people">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pro-inactive">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-neutral">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pro-active">
      <value value="0.02"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>domination</metric>
    <enumeratedValueSet variable="initial-pro-active">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="position-of-people-on-grid">
      <value value="&quot;cluster&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;perfect-separation&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-against-active">
      <value value="0.06"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-against-inactive">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-people">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-neutral">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pro-inactive">
      <value value="0.4"/>
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
0
@#$#@#$#@
