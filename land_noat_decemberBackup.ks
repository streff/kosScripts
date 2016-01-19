
//directions
lock radial to ship:obt:velocity:orbit:direction + r(0,90,0).
lock antiradial to ship:obt:velocity:orbit:direction + r(0,-90,0).
lock normal to ship:obt:velocity:orbit:direction + r(-90,0,0).
lock antinormal to ship:obt:velocity:orbit:direction + r(90,0,0).

//local sea level gravity field
SET g TO BODY:MU / BODY:RADIUS^2.
SET hrg TO BODY:MU / (SHIP:ALTITUDE+BODY:RADIUS^2).


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
set myThrust to 0.
list engines in tengs.
for eng in tengs {
set myThrust to myThrust + eng:AVAILABLETHRUST.
}.
return myThrust.
}.

//set up alignment tracking to prevent early burns
set mySteer to retrograde.
lock steering to mySteer.
lock align to abs( cos(facing:pitch) - cos(mySteer:pitch) )
                  + abs( cos(facing:yaw) - cos(mySteer:yaw) )
                  + abs( sin(facing:pitch) - sin(mySteer:pitch) )
                  + abs( sin(facing:yaw) - sin(mySteer:yaw) ).


//figure out if we are going clockwise or anti-clockwise. has to be an easier way...
set long1 to ship:longitude.
wait 1.
set long2 to ship:longitude.

if long1 > long2 {
set retroOrbitDirection to 90.
} else {
set retroOrbitDirection to 270.
}.

if periapsis > 5000 {
//align
wait until align < 0.1.
//drop PE to skim 10m off sealevel
lock throttle to 0.2.
until ship:periapsis < 10 {
if flamecheck() > 0 {stage.}.  //staging call if engine burns out
clearscreen.
print "lowering PE for descent.".
print ship:periapsis.
wait 1.
}.

lock throttle to 0.

clearscreen.
print "PE set.".
wait 1. //dropping to around 5km alt 
print "Coasting to 5k alt.".
set warp to 3.
until alt:radar < 5000 {
clearscreen.
print "Alt: " + alt:radar.
wait 1.

}.
}.

//phase2 - slow orbital speed, control vertical descent at around 10m/s. need to rewrite this section with a sensible control, but it works
//use a crude p control based on changing the pitch of a heading() command to alter verticalspeed
set warp to 0.
set thrott to 0.
lock throttle to thrott.
set pAng to 5.  //set pitch angle to 5 deg to start with
set dT to 0.1.
set vSetpoint to -10. //target vertical speed
set altGate1 to false.  //gate to trigger setting the target descent rate to 0 if we break a set height
set prevV to 0.   //previous vspeed
set KdV to 0.001.   //gain control - wrongly named derivative term
set KpV to 0.1.    //gain control - proportional
set mySteer TO heading(retroOrbitDirection,pAng).   //setup pitch angle & facing
wait until align < 0.05.
if flamecheck() > 0 { set thrott to 0. wait 1. stage. wait 1.}.   //stage if engines are flamed out
set thrott to 8*(ship:mass*g/getThrust()).  //start to slow down
set foreVec to ship:facing:forevector.     //track facing
set travelVec to ship:velocity:surface.    //track direction
lock checkAng to vAng(foreVec, travelVec).  //difference between facing and direction in degrees

//slow down until checkAng or groundspeed break one of the below values
until checkAng < 90 or groundspeed < 10 {
if flamecheck() > 0 { set thrott to 0. wait 1. stage. wait 1.}.   //stage if engines are flamed out
if groundspeed < 80 {set thrott to 4*(ship:mass*g/getThrust()).}.  //ease off throttle at low speeds

//track error and direction changes
set currentV to verticalspeed.
set ttg to alt:radar/currentV.
set vErr to vSetpoint-currentV.
set vDer to (currentV-prevV)/dt.
set foreVec to ship:facing:forevector.
set travelVec to ship:velocity:surface.

//resultant change in pitch
set vOut to (KpV*vErr) + (KdV*vDer).
//pitch gates
set pAng to max(-1,(min(89,(pAng+vOut)))).
//apply the pitch change
set mySteer TO heading(retroOrbitDirection,pAng).
set prevV to currentV.
//read all about it
clearscreen.
print "checkAng: " + checkAng.
print "currentV: " + currentV.
print "currentAlt: " + alt:radar.
print "Time to ground@this rate: " + round(ttg).
print "vErr: " + vErr.
print "vDer: " + vDer.
print "vOut: " + vOut.
print "pAng: " + pAng.
print "KdV: " + KdV.
print "KpV: " + KpV.

//ground avoidance for long slow (low twr) deceleration burns
if altGate1 = false and alt:radar < 800 {set vSetpoint to 0. set altGate1 to true.}.
wait dT.
}.

//recover for vertical
set thrott to 0.
set mySteer to up.
wait until align < 0.2.
if flamecheck() > 0 { set thrott to 0. wait 1. stage. wait 1.}.   //stage if engines are flamed out
set thrott to 0.8 * ((ship:mass * g) / getThrust()).



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



clearscreen.
print "alt p: " + pad:terrainheight.
print "alt n: " + nDiff.
print "alt s: " + sDiff.
print "alt e: " + eDiff.
print "alt w: " + wDiff.

print "nAng n: " + nAng.
print "sAng s: " + sAng.
print "eAng e: " + eAng.
print "wAng w: " + wAng.

SET VDP TO VECDRAWARGS(
              pad:ALTITUDEPOSITION(pad:TERRAINHEIGHT+100),
              pad:POSITION - pad:ALTITUDEPOSITION(pad:TERRAINHEIGHT+100),
              red, "THIS IS THE SPOT", 1, true).

SET VDN TO VECDRAWARGS(
              padNorth:ALTITUDEPOSITION(padNorth:TERRAINHEIGHT+100),
              padNorth:POSITION - padNorth:ALTITUDEPOSITION(padNorth:TERRAINHEIGHT+100),
              red, "THIS IS THE NORTH", 1, true).
			  
set iPad to iPad + 1.
wait 0.5.
if (largerAngle < 7) { 
return true.
}.
}.
Set rootPad to latlng(latitude,longitude).


FROM {local newLat is -20.} UNTIL newLat = 20 STEP {set newLat to newLat + 5.} DO {
	FROM {local newLng is -20.} UNTIL newLng = 20 STEP {set newLng to newLng + 5.} DO {
		set pad to latlng(rootPad:lat + (newLat*scaleLength), rootPad:lng + (newLng*scaleLength)).
		if padFlat() = true {break.}.
	}.
}.


//vertical descent
unlock all.
run landVert(pad).


