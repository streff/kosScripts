declare parameter padTrgLat, padTrgLng.
SET g TO BODY:MU / BODY:RADIUS^2.
SET hrg TO BODY:MU / (SHIP:ALTITUDE+BODY:RADIUS^2).
set bodyRadius to body:radius.
set bodyMass to body:mass.
set r to ship:body:radius.

//check if any engines are flamed out, called during burn loops.
declare function flamecheck {
set flamed to 0.
list engines in engs.
for eng in engs {
if eng:flameout = "True" {set flamed to flamed + 1.}.
}.
return flamed.
}.

set currentPitch to 90 - vectorangle(up:vector,ship:facing:forevector).
set currentYaw to 90 - vectorangle(up:vector,ship:facing:starvector).

set mySteer to retrograde.
lock steering to mySteer.
lock align to abs( cos(facing:pitch) - cos(mySteer:pitch) )
                  + abs( sin(facing:pitch) - sin(mySteer:pitch) )
                  + abs( cos(facing:yaw) - cos(mySteer:yaw) )
                  + abs( sin(facing:yaw) - sin(mySteer:yaw) ).

declare function getThrust {
if flamecheck() > 0 { lock throttle to 0. wait 0.5. stage. wait 0.5.}.  
set myThrust to 0.
list engines in tengs.
for eng in tengs {
set myThrust to myThrust + eng:AVAILABLETHRUST.
}.
return myThrust.
}.

// This function rotates ship's orbit by burning normally at specified time
// BY given amomunt (not TO angle, but BY angle).
function change_inclination{
	parameter
		t,
		ang.
	
	local r is (body:position-positionat(ship,t)).
	local actual_vel is velocityat(ship,t):orbit.
	local normal_vel is VCRS(actual_vel,r):normalized*actual_vel:mag.
	return make_node_t_deltav(t,actual_vel*(cos(ang)-1)+normal_vel*sin(ang)).
}

function make_node_t_deltav{
	parameter
		t,
		dv.
	
	local pro_unit is velocityat(ship,t):orbit:normalized.
	local rad_unit is -VXCL(pro_unit,body:position-positionat(ship,t))
		:normalized.
	local nor_unit is VCRS(pro_unit,rad_unit).
	return node(t,rad_unit*dv,nor_unit*dv,pro_unit*dv).
}
set mySteer to retrograde.
lock steering to mySteer.
wait 2.

//establish opposite longitude from target for deorbit burn
//establish & hit inclination required to hit the latitude

//tan[latitude] = 0.5 * tan[inclination]
//Therefore...
//inclination = arctan[tan[latitude] / 0.5]
set targetInclination to arctan(tan(padTrgLat)).

set h1 to r+((ship:apoapsis+ship:periapsis)/2).
//set h2 to r+target:altitude.
set h2 to r + 1000.
set ra to r +(periapsis+apoapsis)/2.

set CshipPeriod to ship:obt:period.
//set CtgtPeriod to target:obt:period.
set CtgtPeriod to Body:ROTATIONPERIOD.
set CshipPeriod1Deg to CshipPeriod/360.
set CtgtPeriod1Deg to CtgtPeriod/360.

//work out current phase angle to target
//set cAngle1 to obt:lan+obt:argumentofperiapsis+obt:trueanomaly.
set cAngle1 to ship:longitude.
//set cAngle2 to target:obt:lan+target:obt:argumentofperiapsis+target:obt:trueanomaly.
set cAngle2 to padTrgLng.
set CurrentPhs to cAngle2-cAngle1.
set CurrentPhs to CurrentPhs-360*floor(CurrentPhs/360).

//lead distance - amount of an orbit the target will do in the time taken to transfer from h1 to h2.
//set Pt to 0.5*((h1+h2+(2*r))/(2*r+2*h2))^1.5.
set h1 to ship:altitude.
set hX to (h1+h2)/2.
set Pt to 1/(2*sqrt(h2^3/hX^3)).
//that same orbit chunk in degrees
set Phshft to 360*Pt.
set PhsInsert to 180 - Phshft.

set PhaseError to CurrentPhs - PhsInsert.
if PhaseError < 0 {set PhaseError to 360+PhaseError.}.

set timeToCorrectPhase to PhaseError*CshipPeriod1Deg.
set additionalErrorDeg to timeToCorrectPhase/CtgtPeriod1Deg.
set totalErrorDeg to PhaseError+additionalErrorDeg.

set insertPoint to totalErrorDeg*CshipPeriod1Deg.



//calculate deltaV required for transfer to targets altitude
//set reqDV to sqrt((ship:mass*g)/(r+h1))*sqrt(2(r+h2)/((r+h1)+(r+h2)))-1.
set ps to V(0,0,0) - body:position.
set smas to ps:mag.
set vom to velocity:orbit:mag.
set va to sqrt( vom^2 - 2*body:mu*(1/ra - 1/(r + altitude))).
set smah to (ra + h2)/2.
set deltaV1 to sqrt(va^2 - body:mu * (1/smah - 1/smas)).
set deltaV to deltaV1 - va.

//tilt node
set tiltPoint to insertPoint - (CshipPeriod * 0.25).
set tiltAmount to targetInclination - ship:obt:inclination.
set alignNode to change_inclination(TIME:SECONDS+tiltPoint, tiltAmount).
add alignNode.

//add deorbit node
SET transferNode to NODE(TIME:SECONDS+insertPoint, 0, 0, deltaV).
add transferNode.

//do tiltnode
WARPTO(TIME:SECONDS + tiltPoint-60).
run donode.
remove alignNode.

set betweenTime to insertPoint - tiltPoint.

//do deorbitnode
WARPTO(TIME:SECONDS + betweenTime-60).
run donode.
wait 1.
remove transferNode.

//coast to PE
WARPTO(TIME:SECONDS+(eta:periapsis*0.8)).
until eta:apoapsis < eta:periapsis or alt:radar < 500 {
wait 1.

}.

set align to 0.
set mySteer to retrograde.
lock align to abs( cos(facing:pitch) - cos(mySteer:pitch) )
                  + abs( sin(facing:pitch) - sin(mySteer:pitch) )
                  + abs( cos(facing:yaw) - cos(mySteer:yaw) )
                  + abs( sin(facing:yaw) - sin(mySteer:yaw) ).

lock steering to mySteer.
until align < 0.3 {wait 0.1.}.

SET northPole TO latlng(90,0).
LOCK retroOrbitDirection TO mod(360 - northPole:bearing,360).
set pAng to 5.
set vSetpoint to -10. //target vertical speed
set altGate1 to false.
set prevV to 0.
set prevSV to groundspeed+100.
set KdV to 0.001.
set KpV to 0.05.
set mySteer TO heading(retroOrbitDirection,pAng).
wait until align < 0.05.
lock throttle to 8*(ship:mass*g/ship:maxthrust).
set foreVec to ship:facing:forevector.
set travelVec to ship:velocity:surface.
lock checkAng to vAng(foreVec, travelVec).

until checkAng < 90 or groundspeed < 10 {
if flamecheck() > 0 {stage. wait 0.25.}.
if groundspeed < 100 {lock throttle to 4*(ship:mass*g/ship:maxthrust).}.
set currentV to verticalspeed.
set ttg to alt:radar/currentV.
set vErr to vSetpoint-currentV.
set vDer to (currentV-prevV)/dt.
set foreVec to ship:facing:forevector.
set travelVec to ship:velocity:surface.

set vOut to (KpV*vErr) + (KdV*vDer).

set pAng to max(-1,(min(89,(pAng+vOut)))).
set mySteer TO heading(retroOrbitDirection,pAng).
set prevV to currentV.
set prevSV to groundspeed.
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
if altGate1 = false and alt:radar < 200 {set vSetpoint to 0. set altGate1 to true.}.
wait dT.
}.

//phase2 - 
set TargHDist to 0.
set mySteer to retrograde.
lock steering to mySteer.
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

