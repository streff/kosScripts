// circularise at ap
SET g TO BODY:MU / BODY:RADIUS^2.
SET hrg TO BODY:MU / (SHIP:ALTITUDE+BODY:RADIUS^2).
set bodyRadius to body:radius.
set bodyMass to body:mass.

declare function getThrust {
set myThrust to 0.
list engines in tengs.
for eng in tengs {

set myThrust to myThrust + eng:AVAILABLETHRUST.
}.
return myThrust.

}.
print "Circularising..".


  lock throttle to 0.
  set orbitBody to ship:body.
  set deltaA to getThrust()/mass.
  set radiusAtAp to bodyRadius + ship:apoapsis.
  
  set orbitalVelocity to bodyRadius * sqrt(g/radiusAtAP).
  set APVelocityVec to velocityat(ship, time:seconds+eta:Apoapsis).
  set apVelocity to APVelocityVec:orbit:mag.


  set deltaV to (orbitalVelocity - APVelocity).
  
  set timeToBurn to deltaV/deltaA.
  print "Time to Burn: " + round(timeToBurn).

  SET orbitNode to NODE( TIME:SECONDS+eta:apoapsis, 0, 0, deltaV ).
  add orbitNode.


run donode.

remove orbitNode. 