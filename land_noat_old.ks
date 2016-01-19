set bodyRadius to body:radius.
set bodyMass to body:mass.
SET g TO BODY:MU / BODY:RADIUS^2.
lock hrgrv to body:mu/(altitude+body:radius)^2.
lock ln to vectorangle(up:vector,ship:facing:forevector).
lock hvt to (mass * hrgrv)/ship:maxthrust.
lock angthrt to hvt / sin(90-ln).

set currentPitch to 90 - vectorangle(up:vector,ship:facing:forevector).
set currentYaw to 90 - vectorangle(up:vector,ship:facing:starvector).

set bodyCirc to 2*Constant():PI*body:Radius.
set longLength to bodyCirc/360.
set meterlength to 1/longlength.
set dT to 0.1.
set Latlength to bodyCirc/360.

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

				  
set long1 to ship:longitude.
wait 1.
set long2 to ship:longitude.

if long1 > long2 {

set retroOrbitDirection to 90.


} else {

set retroOrbitDirection to 270.

}.

  
wait until align < 0.1.

lock throttle to 0.2.

until ship:periapsis < 10 {
if flamecheck() > 0 {stage.}.
clearscreen.
print "lowering PE for descent.".
print ship:periapsis.
wait 0.1.
}.

lock throttle to 0.
clearscreen.
print "PE set.".
wait 2.
print "Coasting to 1k alt.".
set warp to 3.
until alt:radar < 5000 {
clearscreen.
print "Alt: " + alt:radar.
wait 1.

}.
set warp to 0.
set pAng to 5.

set vSetpoint to -10. //target vertical speed
set altGate1 to false.
set prevV to 0.
set prevSV to surfacespeed+100.
set KdV to 0.001.
set KpV to 0.05.
set mySteer TO heading(retroOrbitDirection,pAng).
wait until align < 0.05.
lock throttle to 8*(ship:mass*g/ship:maxthrust).
set foreVec to ship:facing:forevector.
set travelVec to ship:velocity:surface.
lock checkAng to vAng(foreVec, travelVec).

until checkAng < 90 or surfacespeed < 10 {
if flamecheck() > 0 {stage. wait 0.25.}.
if surfacespeed < 100 {lock throttle to 4*(ship:mass*g/ship:maxthrust).}.
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
set prevSV to surfacespeed.
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
gear off.
set grset to false.
lock throttle to 0.
set pAng to 90.
set mySteer TO heading(retroOrbitDirection,pAng).
wait until align < 0.05.

set mySteer TO up+R(0, 0, 90).
set vSetpoint to -10. //target vertical speed
set LongSetpoint to 0. //target longitude h speed
set LatSetpoint to 0. //target latitude h speed

set cX to ship:velocity:surface:x.
set prevX to ship:velocity:surface:x.
set cY to ship:velocity:surface:y.
set prevY to ship:velocity:surface:y.
set prevV to verticalspeed.
set KpV to 0.05.
set KiV to 0.5.
set KdV to 0.3.
set KpLg to 0.8.
set KiLg to 0.05.
set KdLg to 0.1.
set KpLt to 0.8.
set KiLt to 0.05.
set KdLt to 0.1.
set maxPitch to 15.
set maxYaw to 15.
set minPitch to -15.
set minYaw to -15.

set iV to 0.
set Dv to 0.

lock Pv to vSetpoint - verticalspeed.
set Pv0 to Pv.


LOCK PLg to LongSetpoint - cX.
set PLg0 to Plg.
set iLg to 0.
set dLg to 0.
LOCK Plt to LatSetpoint - cy.
set PLt0 to Plt.
set iLt to 0.
set dLt to 0.
set pitchAng to 0.
set yawAng to 0.
LOCK dthrott TO (KpV * Pv )+ (KiV * iV) + (Kdv * Dv).
LOCK dpAng TO KpLg * Plg + KiLg * Ilg + KdLg * dLg.
LOCK dyAng TO KpLt * Plt + KiLt * Ilt + KdLt * dLt.
LOCK steering to up+r(yawAng,pitchAng,0).
wait dT.
set throt to 0.
lock throttle to throt.
set vDisplayT to time:seconds.
set t0 to time:seconds.

until ship:status = "Landed" {
if flamecheck() > 0 {stage.}.




set vDT to time:seconds - t0.
if vDT > 0 {
set iV to max(-300, min(300, iV + Pv * vDT)).
set Dv TO (Pv - Pv0) / vDT.
set throt to max(0.2*(ship:mass*g/ship:maxthrust),(min(2.5*(ship:mass*g/ship:maxthrust),(throt + dthrott)))).
}.
set cX to ship:velocity:surface:x.
if vDT > 0 {
set iLg to iLg + PLg * vDT.
set DLg TO (PLg - PLg0) / vDT.

set pitchAng to max(minPitch,(min(maxPitch,(pitchAng - dpAng)))).
}.
set cY to ship:velocity:surface:y.
if vDT > 0 {
set iLt to iLt + PLt * vDT.
set DLt TO (PLt - PLt0) / vDT.

set yawAng to max(minYaw,(min(maxYaw,(yawAng - dyAng)))).
}.


set prevX to ship:velocity:surface:x.
set prevY to ship:velocity:surface:y.
set t0 to time:seconds.

if time:seconds - vDisplayT > 0.5 {
clearscreen.
print "currentV: " + verticalspeed.
print "throt: " + throt.
print "dthrott: " + dthrott.
print "Pv: " + Pv + "  KpV: " + KpV.
print "iV: " + iV + "  KiV: " + KiV.
print "dV: " + dV + "  KdV: " + KdV.
print "Plg: " + Plg + "  KpLg: " + KpLg.
print "iLg: " + iLg + "  KiLg: " + KiLg.
print "dLg: " + dLg + "  KdLg: " + KdLg.
print "Plt: " + Plt + "  KpLt: " + KpLt.
print "iLt: " + iLt + "  KiLt: " + KiLt.
print "dLt: " + dLt + "  KdLt: " + KdLt.
print "dpAng: " + dpAng + "  dyAng: " + dyAng.
print "pitchAng: " + pitchAng + "  yawAng: " + yawAng.
print "dT: " + vdT + "t0: " + t0.
print "-------------------------------".
print "X: " + ship:velocity:surface:x.
print "Y: " + ship:velocity:surface:y.
print "Z: " + ship:velocity:surface:z.
set vDisplayT to time:seconds.
}.

if grset = false and gear = false and alt:radar < 45 {
set vSetpoint to -2.
gear on.
set grset to true.
set maxPitch to maxPitch/2.
set maxYaw to maxYaw/2.
set minPitch to minPitch/2.
set minYaw to minYaw/2.
}.
wait 0.1.
}.
set ship:control:mainthrottle to 0.
sas on.
clearscreen.
print "landed.".