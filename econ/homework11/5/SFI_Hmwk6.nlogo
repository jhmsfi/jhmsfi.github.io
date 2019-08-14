; A model to illustrate the fitness landscape idea of evolution.

patches-own [ fitness change ]
turtles-own [age prestige clever]
globals [ time ]

to setup 
  ca 
  set time 0
  setup-patches 
  setup-turtles 
end 

; This creates the fitness landscape by assigning a "fitness" variable for each patch, and then
; smoothing it by diffusing the fitness variable to neighbouring 
; patches a number of times specified by the smoothness slider. 
; The fitness variable is then rescaled to lie between 0 and 100, with a range specified by
; the value on the range slider. The landscape is then colored a scale of green with white 
; corresponding to fitness of 100 and black a fitness of 0.
to setup-patches 
  ask patches [ set fitness (random 100) ]
  repeat smoothness [ diffuse fitness 1 ]
  rescale
  color-landscape
end

; The initial turtle population, with random ages and colors is spatially distributed 
; randomly across the landscape. This distribution represents
; a variation in the preferences of the initial academic population.

to setup-turtles
    crt number [
        set prestige 0
        set clever round random-normal 5 2.5
        if (clever < 1) [set clever 1]
        if (shade-of? green color) [ set color red ]
        setxy random-xcor random-ycor ]
end


; Turtles are selected to die with a probability determined by their age and their fitness (see death
; procedure). Surviving turtles are allowed to reproduce to replace lost turtlesXXX. There are two
; additional options. If the landscape is selected to change then the fitness of the patches is allowed
; to change in a way that preserves the degree of smoothness, but allowing peaks and valleys to 
; gradually shift. This is achieved by introducing a patch-own "change" variable that is smoothed
; the appropriate amount before being added to the fitness variable in the update-landscape procedure.


; the other option is to add new turtles at the location of your mouse in order to "speed up" the 
; evolutionary process if the turtles are not evolving to highest fitness over time.

to go
  move
  addprestige
  ifelse immortals? 
  [do-plots
  if changing-landscape? [
      diffuse change 1  ; this will diffuse "smoothness" number of times before the fitness is changed.
      if time > smoothness [update-landscape set time 0 ]
      set time time + 1 ]]
  [death
  birth
  do-plots
  if changing-landscape? [
      diffuse change 1  ; this will diffuse "smoothness" number of times before the fitness is changed.
      if time > smoothness [update-landscape set time 0 ]
      set time time + 1 ]]
  tick
end


; Turtles compare their current location to neighboring locations in search of better research projects.
; The more clever an individual is, the larger search radius s/he can employ and the larger number of samples
; s/he can draw. 

to move
  ask turtles
  [move-to max-one-of patches in-radius clever[fitness]]
end


; Each agent who contributes to an idea accumulates prestige. (This may be analagous to more citations,
; followers, fawning graduate students, etc). More prestige means increased potential for idea growth.
; Prestige is a function of the quality of the project, the agent's past work/research, and the prestige of
; fellow researchers.

to addprestige
  ask turtles [
    let meanP mean [prestige] of turtles-on neighbors 
    set prestige prestige + 0.5 * [fitness] of patch-here + 0.1 * meanP 
  ]
end
; This is the procedure where the fitness of a turtle as determined by its location on the landscape 
; comes into play. If a turtle is older than a random number between 0 and the fitness of its location
; its project dies. In this way fitter turtles tend to live longer and hence have more opportunities 
; to reproduce and spread their ideas. 
to death  
    ask turtles [
        set age age + 1
        if age > (random fitness) [
            die] ] 
end


; Turtles are selected at random to reproduce until the maximum number supported by the environment is
; reached. Probability of reproduction is not directly related to fitness. Fitness of ideas is
; related to probability of surviving to reproductive age and number of offspring produced. However in this
; model we assume that all living turtles have the same probability of reproduction,
; and fitness only relates to probability survival.
to birth
        let growth number - count turtles
        repeat growth [
            ask one-of turtles [
                hatch 1 [
                    set age 0
                    set prestige 0
                    set clever round random-normal 5 2.5
                    if (clever < 1) [set clever 1]
                    setxy random-xcor random-ycor
                   ; jump (random-float mutation)
                    rt random 360  ]  ] ]
end


; This a simple linear rescaling that is centered on a fitness of 50 with a total range determined
; by the slider. The maximum allowed range is 100 because we want the maximum allowed fitness to be 
; 100 and the mininum allowed fitness to be 0. If the range is allowed to be larger than 100 then 
; the coloring of the landscape will look strange.
to rescale
   let highest max [ fitness ] of patches
   let lowest min [ fitness ] of patches
   ifelse (highest - lowest) = 0 
      [ask patches [set fitness 50] ]
      [ask patches [ set fitness range * (fitness - lowest) / (highest - lowest) + (99 - range) / 2] ]
end

; Color the patches a scale of green according to their fitness value, with 0 being black and 100 being 
; white.
to color-landscape
     ask patches [ set pcolor scale-color green fitness 0 100]
end     

to do-plots
  set-current-plot "Average Idea Greatness"
  set-current-plot-pen "Low" 
  plot mean [ fitness ] of turtles with [clever < 2.5]
  set-current-plot-pen "Average"
  plot mean [fitness] of turtles with [clever > 2.5 and clever < 7.5]
  set-current-plot-pen "High"
  plot mean [fitness] of turtles with [clever > 7.5]
  
  set-current-plot "Prestige vs Clever"
  set-current-plot-pen "Low" 
  plot mean [ prestige ] of turtles with [clever < 2.5]
  set-current-plot-pen "Average"
  plot mean [prestige] of turtles with [clever > 2.5 and clever < 7.5]
  set-current-plot-pen "High"
  plot mean [prestige] of turtles with [clever > 7.5]
end

; when the landscape is allowed to change over time add the appropriately smoothed change variable
; to the fitness variable, and then recalculate the change for the next time step.
to update-landscape 
  ask patches [set fitness fitness + rate-of-exploitation * change
               ifelse (count turtles-on neighbors + count turtles-here > 1 )
               [set change (-1 * count turtles-on neighbors - count turtles-here ) ]
               [set change random-normal 0 30 ] ] 
  rescale
  color-landscape
end
@#$#@#$#@
GRAPHICS-WINDOW
511
10
1007
527
40
40
6.0
1
10
1
1
1
0
1
1
1
-40
40
-40
40
0
0
1
ticks

BUTTON
11
10
111
57
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
110
10
208
57
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

SLIDER
13
60
209
93
smoothness
smoothness
0
50
16
1
1
NIL
HORIZONTAL

SLIDER
11
133
210
166
number
number
0
1000
300
1
1
NIL
HORIZONTAL

PLOT
5
300
307
501
Average Idea Greatness
NIL
NIL
0.0
10.0
0.0
100.0
true
true
PENS
"default" 1.0 0 -16777216 true
"High" 1.0 0 -16777216 true
"Average" 1.0 0 -2674135 true
"Low" 1.0 0 -10899396 true

SLIDER
10
209
211
242
rate-of-exploitation
rate-of-exploitation
0
1
0.95
0.05
1
NIL
HORIZONTAL

SWITCH
10
173
211
206
changing-landscape?
changing-landscape?
0
1
-1000

SLIDER
12
96
210
129
range
range
0
100
100
1
1
NIL
HORIZONTAL

SWITCH
11
255
136
288
immortals?
immortals?
1
1
-1000

PLOT
8
513
295
714
Prestige vs Clever
Clever
Prestige
0.0
10.0
0.0
10.0
true
true
PENS
"default" 1.0 0 -16777216 true
"Low" 1.0 0 -10899396 true
"Average" 1.0 0 -2674135 true
"High" 1.0 0 -16777216 true

@#$#@#$#@


RELATED MODELS
--------------
Based on 'Fitness landscape' model by David McAvity.


The original fitness model was created at the Evergeen State College, in Olympia Washington
as part of a series of applets to illustrate principles in physics and biology. 

Funding was provided by the Plato Royalty Grant.
 
The model may be freely used, modified and redistribued provided this copyright is included and the resulting models are not used for profit.

Contact David McAvity at mcavityd@evergreen.edu if you have questions about its use.


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
Circle -7500403 true true 30 30 240

circle 2
false
0
Circle -7500403 true true 16 16 270
Circle -16777216 true false 46 46 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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
Polygon -7500403 true true 60 270 150 0 240 270 15 105 285 105
Polygon -7500403 true true 75 120 105 210 195 210 225 120 150 75

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
