clearscreen.
SET throt TO 0.
LOCK throttle TO throt.
SET tw TO false.
SET thrustlim TO SHIP:AVAILABLETHRUST.
SET accel TO thrustlim/mass.
SET dv TO NEXTNODE:DELTAV:MAG.
SET totdv TO dv.
SET steervec TO NEXTNODE:DELTAV:NORMALIZED.
SET burnTime TO (dv/accel).
SET burnStart TO NEXTNODE:ETA - burnTime/2.

run Rybec_TIER3_warpto(time:seconds + burnstart - 120).
clearscreen.
print "Executing node for " + round(dv,1) + "dV.".
print "   Node in   :".
print "   Burn in   :".
print "   Burn time :".
print "   Burn DV   :".
print "   Steer err :".

when burnStart < 120 then {
    SET tw TO false.
    SET warp TO 0.
    LOCK STEERING TO steervec.
    SET SAS TO FALSE.
}.
until dv < max(0.1,totdv*0.001) {
    if burnStart < 5 {
            SET warp TO 0.
            SAS OFF.
    } elseif tw = true {
        if burnStart < 199 {
            SET warp TO 2.
        } elseif burnStart < 399 {
            SET warp TO 4.
        }
    }
    SET steervec TO (steervec * 5 + NEXTNODE:DELTAV:NORMALIZED):NORMALIZED.
    SET steerErr TO vang(steervec,facing:vector).
    
    if steerErr<1 and burnStart>10 {run Rybec_TIER3_warpto(time:seconds + burnStart).}
    
    if burnStart <= 0 {SET throt TO burnTime * 2 + 0.02.}
    if steerErr > 5 {SET throt TO 0.}
    SET thrustlim TO SHIP:AVAILABLETHRUST.
    SET accel TO thrustlim/mass.
    SET dv TO NEXTNODE:DELTAV:MAG.
    SET burnTime TO (dv/accel).
    SET burnStart TO NEXTNODE:ETA - burnTime/2.
    print round(NEXTNODE:ETA,2) + "     " at (15,1).
    print round(burnStart,2) + "     " at (15,2).
    print round(burnTime,2) + "     " at (15,3).
    print round(dv,2) + "     " at (15,4).
    print round(steerErr,1) + "     " at (15,5).
    SET oldsteer TO steervec.
    wait 0.01.
}
SET throt TO 0.
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
UNLOCK THROTTLE.
UNLOCK STEERING.
print "Burn complete, stabilizing rotation...".
SAS ON.
remove nextnode.
clearscreen.
//wait 0.5. //Thou shalt wait, lest ye incur bizarre throttle bug