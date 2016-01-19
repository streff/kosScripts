declare parameter targetLong.
set targetAlt to 2863330.

set bodyRadius to body:radius.
set bodyMass to body:mass.
set r to ship:body:radius.
SET g TO BODY:MU / BODY:RADIUS^2.
set h1 to r+((ship:apoapsis+ship:periapsis)/2).
//set h2 to r+target:altitude.
set h2 to r + targetAlt.
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
set cAngle2 to targetLong.
set CurrentPhs to cAngle2-cAngle1.
set CurrentPhs to CurrentPhs-360*floor(CurrentPhs/360).

//lead distance - amount of an orbit the target will do in the time taken to transfer from h1 to h2.
//set Pt to 0.5*((h1+h2+(2*r))/(2*r+2*h2))^1.5.
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

print "phase shift reqd: " + Phshft.
print "current phase to tgt: " + CurrentPhs.
print "er: " + PhaseError.
print "hohmann insertion angle: " + PhsInsert.
print "timeToCorrectPhase: " + timeToCorrectPhase.
print "additionalErrorDeg: " + additionalErrorDeg.
print "totalErrorDeg: " + totalErrorDeg.
print "insertPoint: " + insertPoint.

//calculate deltaV required for transfer to targets altitude
//set reqDV to sqrt((ship:mass*g)/(r+h1))*sqrt(2(r+h2)/((r+h1)+(r+h2)))-1.
set ps to V(0,0,0) - body:position.
set smas to ps:mag.
set vom to velocity:orbit:mag.
set va to sqrt( vom^2 - 2*body:mu*(1/ra - 1/(r + altitude)) ).
set smah to (ra + h2)/2.
set deltaV1 to sqrt(va^2 - body:mu * (1/smah - 1/smas)).
set deltaV to deltaV1 - va.
SET transferNode to NODE( TIME:SECONDS+insertPoint, 0, 0, deltaV ).
add transferNode.

WARPTO(TIME:SECONDS + insertPoint-60).
run donode.
wait 1.
remove transferNode.
