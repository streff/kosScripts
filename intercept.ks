//circularise in SOI from escape trajectory
declare parameter tgtBody, tgtPeriapsis.


set bodyRadius to body:radius.
set bodyMass to body:mass.
SET g TO BODY:MU / BODY:RADIUS^2.

lock dirRadial to ship:obt:velocity:orbit:direction + r(0,90,0).
lock dirAantiradial to ship:obt:velocity:orbit:direction + r(0,-90,0).
lock dirNormal to ship:obt:velocity:orbit:direction + r(-90,0,0).
lock dirAntinormal to ship:obt:velocity:orbit:direction + r(90,0,0).

declare function flamecheck {
set flamed to 0.
list engines in engs.
for eng in engs {
if eng:flameout = "True" {set flamed to flamed + 1.}.
}.
return flamed.

}.

set mySteer to retrograde.
lock steering to mySteer.
lock align to abs( cos(facing:pitch) - cos(mySteer:pitch) )
                  + abs( sin(facing:pitch) - sin(mySteer:pitch) )
                  + abs( cos(facing:yaw) - cos(mySteer:yaw) )
                  + abs( sin(facing:yaw) - sin(mySteer:yaw) ).
				  
				  
until ship:body = tgtBody {
clearscreen.
print "waiting for SOI intercept".
wait 1.
}.
print "At target body " + tgtBody.
wait 1.

//avoid collisions
if periapsis < tgtPeriapsis {
print "Periapsis too low, raising.".
set mySteer to dirRadial.

wait until align < 0.05.

until periapsis > tgtPeriapsis {
if align < 0.1 {
if flamecheck() > 0 {stage.}.
lock throttle to 0.4.
} else {
lock throttle to 0.
}.
}.
}.

if periapsis > tgtPeriapsis*1.2 {
print "Periapsis too high, lowering.".
set mySteer to retrograde.

wait until align < 0.05.

until periapsis < tgtPeriapsis {

if align < 0.1 {
if flamecheck() > 0 {stage.}.
lock throttle to 0.4.
} else {
lock throttle to 0.
}.
}.
}.

lock throttle to 0.
clearscreen.
print "Periapsis adjusted for orbital capture.".

print "preparing for circularisation burn.".

SET g TO BODY:MU / BODY:RADIUS^2.
set bodyRadius to body:radius.
set bodyMass to body:mass.

  set orbitBody to ship:body.
  set radiusAtPE to orbitBody:radius + ship:periapsis.
  set orbitalVelocity to bodyRadius * sqrt(g/radiusAtPE).
 
 set PEVelocityVec to velocityat(ship, time:seconds+eta:periapsis).
 set PEVelocity to PEVelocityVec:orbit:mag.
 set deltaV to (orbitalVelocity - PEVelocity).

	  
SET captureNode to NODE( TIME:SECONDS+eta:periapsis, 0, 0, deltaV ).
add captureNode.
set mySteer to Nextnode.
wait 2.
set wtime to ETA:Periapsis - 120.
run warpto(wtime).
set warp to 0.
run donode.
remove captureNode.
