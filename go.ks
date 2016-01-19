//order of operations - 
//  1. spawn on runway
//  2. engage brakes
//  3. run script
//  4. pray to $deity
//  5. release brakes
//  6. manage throttle directly, manage roll & ascent rate via AGs during flight.

set tAscentRate to 100.
lock cAscentRate to ship:verticalspeed.

set dt to 0.1.

set maxAscOut to 85.
set minAscOut to -85.

set maxPitchOut to 1.
set minPitchOut to -1.

set KpAscentRate to 1.
set KdAscentRate to 0.05.

set KpPitch to 0.05.
set KdPitch to 0.001.

set KpRoll to 0.3.


set ship:control:pitch to 0.
set ship:control:roll to 0.
set desiredPitch to 0.
set desiredRoll to 0.
set prevAscentRate to 0.
set prevPitch to 0.
set prevRoll to 0.

on AG1 {Set tAscentRate to tAscentRate - 10.PRESERVE. }.
on AG2 {Set tAscentRate to tAscentRate + 10.PRESERVE. }.

on AG3 {Set KpAscentRate to KpAscentRate - 0.1.PRESERVE. }.
on AG4 {Set KpAscentRate to KpAscentRate + 0.1.PRESERVE. }.

on AG5 {Set KdAscentRate to KdAscentRate - 0.01.PRESERVE. }.
on AG6 {Set KdAscentRate to KdAscentRate + 0.01.PRESERVE. }.

on AG7 {Set KpPitch to KpPitch - 0.01.PRESERVE. }.
on AG8 {Set KpPitch to KpPitch + 0.01.PRESERVE. }.

on AG9 {Set KdPitch to KdPitch + 0.001.PRESERVE. }.
on AG10 {Set KdPitch to KdPitch - 0.001.PRESERVE. }.


//pre takeoff
wait until brakes = false.

//takeoff
SAS on.
print "SAS On".
wait 1.
//lock throttle to 1.
//print "Throttle to max".
wait 1.
stage.
print "Ignite engines...".

until surfacespeed > 100 {
clearscreen.
print "surfacespeed: " + surfacespeed.
wait 0.1.
}.

clearscreen.
SAS off.
set ship:control:pitch to 0.5.
until alt:radar > 50 {
clearscreen.
print "alt:radar: " + alt:radar.
wait 0.1.
}.

gear off.

//post take-off
until gear = true {

set currentPitch to 90 - vectorangle(up:vector,ship:facing:forevector).
set currentRoll to 90 - vectorangle(up:vector,ship:facing:starvector).


//ascent rate controls
set ascErr to tAscentRate-cAscentRate.
set derAscentRate to (cAscentRate-prevAscentRate)/dt.

set ascOut to (KpAscentRate*ascErr) + (KdAscentRate*derAscentRate).


//max and min values trapped here
if ascOut > 90 {set ascOut to maxAscOut.}.
if ascOut < -90 {set ascOut to minAscOut.}.


//output pitch change requirement
set desiredPitch to ascOut.


set pitchErr to desiredPitch-currentPitch.
set derPitch to (currentPitch-prevPitch)/dt.

set pitchOut to (KpPitch*pitchErr)+(KdPitch*derPitch).

if pitchOut > 1 {set pitchOut to maxPitchOut.}.
if pitchOut < -1 {set pitchOut to minPitchOut.}.

set ship:control:pitch to pitchOut.

//roll control
set rollErr to desiredRoll-currentRoll.
set rollDer to 0-(rollErr/180).
set ship:control:roll to rollDer.

set prevAscentRate to cAscentRate.
set prevPitch to currentPitch.
set prevRoll to currentRoll.

clearscreen.
print "cAscentRate: " + verticalspeed.
print "tAscentRate: " + tAscentRate.
print "desired pitch: " + desiredPitch.
print "currentPitch: " + currentPitch.
print "pitch controls: " + ship:control:pitch.
print "desired roll: " + desiredRoll.
print "current roll: " + currentRoll.
print "roll controls: " + ship:control:roll.
print "+++++++++++++++".
print "KpAscentRate: " + KpAscentRate.
print "KdAscentRate: " + KdAscentRate.
print "KpPitch: " + KpPitch.
print "KdPitch: " + KdPitch.

wait dt.
}.