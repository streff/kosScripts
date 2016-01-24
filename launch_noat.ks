//launch no atmosphere
SET g TO BODY:MU / BODY:RADIUS^2.
SET hrg TO BODY:MU / (SHIP:ALTITUDE+BODY:RADIUS^2).
set bodyRadius to body:radius.
set bodyMass to body:mass.

set mysteer to up.
lock align to abs( cos(facing:pitch) - cos(mySteer:pitch) )
                  + abs( sin(facing:pitch) - sin(mySteer:pitch) )
                  + abs( cos(facing:yaw) - cos(mySteer:yaw) )
                  + abs( sin(facing:yaw) - sin(mySteer:yaw) ).

lock STEERING to mysteer.
set mysteer to up + R(0,0,180).
lock throttle to 1.

wait until apoapsis > 500.

set mysteer to up + R(0,-45,180).

wait until apoapsis > 15000.
lock throttle to 0.
wait 1.
print "Circularising..".


  lock throttle to 0.
  set orbitBody to ship:body.
  set deltaA to maxthrust/mass.
  set radiusAtAp to bodyRadius + ship:apoapsis.
  
  set orbitalVelocity to bodyRadius * sqrt(g/radiusAtAP).
  set APVelocityVec to velocityat(ship, time:seconds+eta:Apoapsis).
  set apVelocity to APVelocityVec:orbit:mag.


  set deltaV to (orbitalVelocity - APVelocity).
  
  set timeToBurn to deltaV/deltaA.
  print "Time to Burn: " + round(timeToBurn).

  SET orbitNode to NODE( TIME:SECONDS+eta:apoapsis, 0, 0, deltaV ).
  add orbitNode.
  set mySteer to prograde.
  wait until align < 0.2.

run donode.

remove orbitNode.

clearscreen.
print "......................".
print "In Orbit".
print "ALT: " + ship:altitude.
print "OBT: " + orbitalVelocity.
print "VEL: " + velocity:orbit:mag.
print "AP: " + apoapsis + " PE: " + periapsis.

      print "Circularization complete. Shutting down launch script.".
      set ship:control:pilotmainthrottle to 0.

lock throttle to 0.

unlock all.

//end program