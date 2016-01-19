//launch no atmosphere return to kerbin

print "------------------------------".
print "Preparing for launch from " + ship:body.
print "------------------------------".
wait 2.
SET g TO BODY:MU / BODY:RADIUS^2.

if ship:body = Mun set FINAL to 50000.
if ship:body = Minmus set FINAL to 15000.

declare function getThrust {
set myThrust to 0.
list engines in tengs.
for eng in tengs {
set myThrust to myThrust + eng:thrust.
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


print "3". wait 1.
print "2". wait 1.
print "1". wait 1.
print "Launch!". 
sas off. 
lock throttle to 1.8*(ship:mass*g/ship:maxthrust).
wait 10.
clearscreen.
print "Aiming for counterclockwise orbit.".
set mySteer to heading(90,45).
lock throttle to 1.
until apoapsis > FINAL {
clearscreen.
print "AP: " + apoapsis.
print "Verticalspeed: " + verticalspeed.
}.
lock throttle to 0.

clearscreen.
print "preparing for circularisation burn.".

SET g TO BODY:MU / BODY:RADIUS^2.
set bodyRadius to body:radius.
set bodyMass to body:mass.

  set orbitBody to ship:body.
  set radiusAtAP to orbitBody:radius + ship:apoapsis.
  set orbitalVelocity to bodyRadius * sqrt(g/radiusAtAP).
 
 set APVelocityVec to velocityat(ship, time:seconds+eta:Apoapsis).
 set APVelocity to APVelocityVec:orbit:mag.
  set deltaV to (orbitalVelocity - APVelocity).

	  
SET orbitNode to NODE( TIME:SECONDS+eta:apoapsis, 0, 0, deltaV ).
add orbitNode.
set mySteer to orbitNode.	 
run donode.
wait 1.
remove orbitNode.

unlock all.













