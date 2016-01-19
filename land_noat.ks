SET g TO BODY:MU / BODY:RADIUS^2.
SET hrg TO BODY:MU / (SHIP:ALTITUDE+BODY:RADIUS^2).
set bodyRadius to body:radius.
set bodyMass to body:mass.

//check if any engines are flamed out, called during burn loops.
declare function flamecheck {
set flamed to 0.
list engines in engs.
for eng in engs {
if eng:flameout = "True" {set flamed to flamed + 1.}.
}.
return flamed.
}.

declare function getThrust {
if flamecheck() > 0 { lock throttle to 0. wait 0.5. stage. wait 0.5.}.  
set myThrust to 0.
list engines in tengs.
for eng in tengs {
set myThrust to myThrust + eng:AVAILABLETHRUST.
}.
return myThrust.
}.
lock steering to retrograde.
wait 2.
if periapsis > 2000 {
lock steering to retrograde.
//drop PE to skim 5km off sealevel
lock throttle to 0.4.
until periapsis < 1000 {
if flamecheck() > 0 {stage.}.  //staging call if engine burns out
clearscreen.
print "lowering PE for descent.".
print ship:periapsis.
wait 1.
}.

lock throttle to 0.

clearscreen.
print "PE set.".
wait 1. //dropping to around 6km alt 
print "Coasting to ~5k alt.".
set warp to 3.
until alt:radar < 5000 or altitude < 6000 {
clearscreen.
print "Alt: " + alt:radar.
wait 0.5.

}.
}.
set warp to 0.
lock steering to retrograde.
wait 2.
lock throttle to 0.8.
until groundspeed < 10 {wait 0.5.}.
lock throttle to 0.

//phase2 - 
set TargHDist to 0.
lock steering to retrograde.
wait 2.
lock throttle to 1.
until verticalspeed > -2 {
if flamecheck() > 0 {stage.}.  //staging call if engine burns out
wait 0.1.
}.
set cThrust to getThrust().
set thrott to 1.0*((ship:mass*hrg)/cThrust).
lock throttle to thrott.


//recover for vertical
//pick a spot
set scaleLength to 360/((2*body:radius)*3.14).
set iPad to 0.
declare function padFlat {

set padNorth to latlng(pad:lat + (5*scaleLength), pad:lng).
set padSouth to latlng(pad:lat - (5*scaleLength), pad:lng).
set padEast to latlng(pad:lat, pad:lng + (5*scaleLength)).
set padWest to latlng(pad:lat, pad:lng - (5*scaleLength)).

set nDiff to padNorth:terrainheight - pad:terrainheight.
set sDiff to padSouth:terrainheight - pad:terrainheight.
set eDiff to padEast:terrainheight - pad:terrainheight.
set wDiff to padWest:terrainheight - pad:terrainheight.

set nAng to abs(arctan(nDiff/5)).
set sAng to abs(arctan(sDiff/5)).
set eAng to abs(arctan(eDiff/5)).
set wAng to abs(arctan(wDiff/5)).

set nAve to (nAng + sAng)/2.
set eAve to (eAng + wAng)/2.

set largerAngle to max(nAve, eAve).
Lock TargHDist to sqrt(((pad:lat - latitude)^2) + ((pad:lng - longitude)^2))/scaleLength.

clearscreen.
print "scanning area around " + rootPad.
print "alt p: " + pad:terrainheight.
print "alt n: " + nDiff + " : " + nAng.
print "alt s: " + sDiff + " : " + sAng.
print "alt e: " + eDiff + " : " + eAng.
print "alt w: " + wDiff + " : " + wAng.
print "Distance: " + TargHDist.
print "iterations: " + ipad.
			  
set iPad to iPad + 1.
wait 0.1.
if (largerAngle < 7) { 
return true.
}.
}.
Set rootPad to latlng(latitude,longitude).
set padChosen to false.

until padChosen = true {

lock steering to up.
if flamecheck() > 0 { lock throttle to 0. wait 0.5. stage. wait 0.5.}.   //stage if engines are flamed out
set thrott to 1 * ((ship:mass * g) / getThrust()).
lock throttle to thrott.
FROM {local newLat is -20.} UNTIL newLat = 20 STEP {set newLat to newLat + 5.} DO {
	FROM {local newLng is -20.} UNTIL newLng = 20 STEP {set newLng to newLng + 5.} DO {
		set pad to latlng(rootPad:lat + (newLat*scaleLength), rootPad:lng + (newLng*scaleLength)).
		if TargHDist > 5000 {set rootPad to latlng(rootPad:lat + (50*scaleLength), rootPad:lng). }
		if flamecheck() > 0 { lock throttle to 0. wait 0.5. stage. wait 0.5.}.   //stage if engines are flamed out
		set thrott to 1 * ((ship:mass * g) / getThrust()).
		lock throttle to thrott.
		if padFlat() = true {break.}.
		}.
	if padFlat() = true {break.}.
	}.
	if padFlat = false {set rootPad to latlng(rootPad:lat, rootPad:lng + (50*scaleLength)). } else {set padChosen to true.}.
}.
clearscreen.
print "*****************".
print "Took " + iPad + " iterations.".
print "slope is " + largerAngle + " degrees.".
print "*****************".
wait 3.
lock throttle to 0.
//vertical descent
unlock all.
lights on.
run landVert(pad).
lights off.

