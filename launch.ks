declare parameter FINAL.

SET g TO BODY:MU / BODY:RADIUS^2.
SET hrg TO BODY:MU / (SHIP:ALTITUDE+BODY:RADIUS^2).
set bodyRadius to body:radius.
set bodyMass to body:mass.

set thrott to 0.
lock throttle to thrott.

declare function getThrust {
set myThrust to 0.
list engines in tengs.
for eng in tengs {

set myThrust to myThrust + eng:AVAILABLETHRUST.
}.
return myThrust.

}.

declare function flamecheck {
set flamed to 0.
list engines in engs.
for eng in engs {
if eng:flameout = "True" {set flamed to flamed + 1.}.
}.

return flamed.

}.
set mysteer to up.
lock align to abs( cos(facing:pitch) - cos(mySteer:pitch) )
                  + abs( sin(facing:pitch) - sin(mySteer:pitch) )
                  + abs( cos(facing:yaw) - cos(mySteer:yaw) )
                  + abs( sin(facing:yaw) - sin(mySteer:yaw) ).

lock STEERING to mysteer.

set gturn to 0.

lock mysteer to up + R(0,0,180).

set SHIP:CONTROL:MAINTHROTTLE to 0.

print "Launch!".
wait 1.
stage.

set thrott to 1.
until altitude > 1000 {

clearscreen.

print "altitude: " + altitude.

print "Waiting for 2k.".

print "Mthrust: " + getThrust().

if flamecheck() > 0 {stage.}.

wait 1.

}.

lock mysteer to up + R(0,gturn,180).


until gturn <= -65 or apoapsis > FINAL {

if flamecheck() > 0 {set thrott to 0. stage. wait 1.}.

set cThrust to getThrust().
set thrott to 1.6*((ship:mass*hrg)/cThrust).


set a1 to altitude/40000.

set a1r to round(a1,2).

if a1r > 1 {set gturn to -65.} else {set gturn to 0-(a1r*40).}.

clearscreen.

print "gturn " + gturn.
print "align: " + align.
print "thrust: " + getThrust().
print "ship:mass: " + ship:mass.
print "hrg: " + hrg.
print "twr: " + cThrust/(ship:mass*hrg).

wait 0.3.

}.
clearscreen.


set thrott to 1.
until apoapsis > FINAL {

if flamecheck() > 0 {stage.}.
clearscreen.
print "holding 65 from vert".
print "AP: " + ship:apoapsis.
print "V: " + ship:velocity:orbit:mag.
print "thrust: " + getThrust().
wait 1.

}.


RCS on.
 

until apoapsis > FINAL AND altitude > 70000 {

clearscreen.

print "gturn " + gturn.

print "align: " + align.
 
set a2 to altitude/FINAL.



set a2r to round(a2,2).

if a2r > 1 {set gturn to -90.} else if a2r < 0.65 {set gturn to -55.} else {set gturn to 0-(a2r*90).}.

 

 if apoapsis < 0.75*FINAL {lock throttle to 1.}.
 if apoapsis > 0.85*FINAL and apoapsis < 0.9*FINAL {ascentthrottle1.}.
 if apoapsis > 0.9*FINAL and apoapsis < FINAL {lock throttle to 0.1.}.
 if apoapsis > FINAL {lock throttle to 0.}.

if flamecheck() > 0 {stage.}.
 

 wait 1.

 }.

lock throttle to 0.
//punt fairings
//set fairing to ship:partsdubbed("AE-FF2 Airstream Protective Shell (2.5m)").
//toggle AG10.

set mySteer to prograde.
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


print "done.".
lock throttle to 0.

unlock all.

//end program

