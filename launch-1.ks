set gConst to 6.67384*10^(0-11).
set bodyRadius to body:radius.
set bodyMass to body:mass.

declare function getthrust {
set ispsum to 0.
set maxthrustlimited to 0.
LIST ENGINES in MyEngines.
for engine in MyEngines {
    if engine:ISP > 0 and engine:ignition = "True" {
        set ispsum to ispsum + (engine:MAXTHRUST / engine:ISP).
        set maxthrustlimited to maxthrustlimited + (engine:MAXTHRUST * (engine:THRUSTLIMIT / 100) ).
    }
}
return maxthrustlimited.
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
lock hrgrv to gConst*bodyMass/((altitude+bodyRadius)^2).
lock hvt to mass*hrgrv/ship:maxthrust.
lock ascentthrottle1 to 1.
lock ascentthrottle2 to 0.8.

set FINAL to 85000.
set gturn to 0.

lock mysteer to up + R(0,0,180).
lock throttle to 0.
lock throttle to 1.

stage.

print "Launch!".
wait 1.
until altitude > 2000 {

clearscreen.

print "altitude: " + altitude.

print "Waiting for 2k.".

if flamecheck() > 0 {stage.}.

wait 1.

}.

lock throttle to ascentthrottle1.

until altitude > 5000 {

if flamecheck() > 0 {stage.}.
lock throttle to ascentthrottle1.
clearscreen.

print "altitude: " + altitude.

print "Waiting for 5k.".



wait 1.



}.

print "over 5k".

lock throttle to ascentthrottle1.


lock mysteer to up + R(0,gturn,180).


until gturn <= -45 or apoapsis > FINAL {

if flamecheck() > 0 {stage.}.

clearscreen.

print "gturn " + gturn.

print "align: " + align.


set a1 to altitude/20000.

set a1r to round(a1,2).

if a1r > 1 {set gturn to -45.} else {set gturn to 0-(a1r*45).}.

if align > 0.2 lock throttle to ascentthrottle2.

if align < 0.2 lock throttle to ascentthrottle1.


wait 1.

}.

until apoapsis > FINAL {

if flamecheck() > 0 {stage.}.

clearscreen.


if align > 0.2 lock throttle to ascentthrottle2.

if align < 0.2 lock throttle to ascentthrottle1.


wait 1.

}.

clearscreen.

print "holding 45".
RCS on.
 

until apoapsis > FINAL AND altitude > 70000 {



print "gturn " + gturn.

print "align: " + align.
 
set a2 to altitude/FINAL.



set a2r to round(a2,2).

if a2r > 1 {set gturn to -90.} else if a2r < 0.45 {set gturn to -45.} else {set gturn to 0-(a2r*90).}.

 

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
toggle AG10.

wait 1.

//comms & panels

//panels on.
toggle AG9.



//arms out

SET hingeList to ship:PARTSDUBBED("Powered Hinge 90 Degrees").



for hinge in hingeList {

until hinge:getmodule("MUMECHTOGGLE"):GETFIELD("rotation") > 89{

hinge:GETMODULE("MUMECHTOGGLE"):doaction("move +", 1).

clearscreen.

print hinge:getmodule("MUMECHTOGGLE"):GETFIELD("rotation").


wait 0.25.

}.

hinge:GETMODULE("MUMECHTOGGLE"):doaction("move +", 0).

}.



//activate comms



set commslist16 to ship:partsdubbed("Communotron 16").

print "Found " + commslist16:length + " Communotron 16s.".

set commslist32 to ship:partsdubbed("Communotron 32").

print "Found " + commslist32:length + " Communotron 32s.".

set commslist88 to ship:partsdubbed("Communotron 88-88").

print "Found " + commslist88:length + " Communotron 88-88s.".

set commslistkr7 to ship:partsdubbed("Reflectron KR-7").

print "Found " + commslistkr7:length + " Reflectron KR-7s.".

set commslistkr14 to ship:partsdubbed("Reflectron KR-14").

print "Found " + commslistkr14:length + " Reflectron KR-14s.".

set commslistgx128 to ship:partsdubbed("Reflectron GX-128").

print "Found " + commslistgx128:length + " Reflectron GX-128s.".

wait 2.



print "Attempting Short range connection...".

if commslist16:length > 0 {commslist16[0]:GETMODULE("ModuleRTAntenna"):DOEVENT("activate").}.

wait 1.



if addons:rt:hasconnection(ship) = true {print "Connected to Network!".} else {print "No Connection to Network.".}.

if addons:rt:haskscconnection(ship) = true {print "Connected to KSC!".} else {print "No Connection to KSC.".}.



print "Attempting Medium range connection...".

if commslist32:length > 0 {commslist32[0]:GETMODULE("ModuleRTAntenna"):DOEVENT("activate").}.



if addons:rt:hasconnection(ship) = true {print "Connected to Network!".} else {print "No Connection to Network.".}.

if addons:rt:haskscconnection(ship) = true {print "Connected to KSC!".} else {print "No Connection to KSC.".}.



print "Attempting Targeted connection...".

if commslist88:length > 0 {

for sat in commslist88 {

sat:GETMODULE("ModuleRTAntenna"):DOEVENT("activate").}.

}.

if commslistgx128:length > 0 {

for sat in commslistgx128 {

sat:GETMODULE("ModuleRTAntenna"):DOEVENT("activate").}.

}.

print "Circularising..".


lock throttle to 0.
  set orbitBody to ship:body.
  set deltaA to maxthrust/mass.
  set radiusAtAp to orbitBody:radius + FINAL.
  set orbitalVelocity to orbitBody:radius * sqrt(9.8/radiusAtAp).
  set apVelocity to sqrt(orbitBody:mu*((2/radiusAtAp)-(1/ship:obt:semimajoraxis))).
  set deltaV to (orbitalVelocity - apVelocity).
  set timeToBurn to deltaV/deltaA.
  lock steering to up + R(0,-90,180).
  print "Time to Burn: " + round(timeToBurn).
  until eta:apoapsis < timeToBurn/2 {
  wait 1.
  }.
    print "Circularizing. V=" + round(orbitalVelocity) + "m/s, T=" + round(timeToBurn) + "s.".
    lock throttle to 1.
    
	until periapsis > FINAL {
	if flamecheck() > 0 {stage.}.
	
	}.
      print "Circularization complete. Shutting down.".
      set ship:control:pilotmainthrottle to 0.


print "done.".
lock throttle to 0.

unlock all.

//end program

s