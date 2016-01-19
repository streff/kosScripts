DECLARE PARAMETER targ.
SET minSafeAltitude TO 7200.
SET spaces TO "          ".
switch to 1.
clearscreen.

SET prog TO 0.
SET eta TO time:seconds+30.
SET deorb TO NODE(eta,0,0,prog).
ADD deorb.
SET eta TO deorb:ETA.
SET bodyrot TO 360 * ((eta + deorb:orbit:period/2) / BODY:ROTATIONPERIOD).
SET periLNG TO body:geopositionof(positionat(ship,time:seconds + eta + deorb:orbit:period/2)):lng.
if (periLNG > 180) {SET periLNG TO periLNG -(360 * CEILING((periLNG - 180) / 360)).} else if (periLNG <= -180) {SET periLNG TO periLNG -(360 * FLOOR((periLNG + 180) / 360)).}
set ang to targ:lng + bodyrot.
if (ang > 180) {SET ang TO ang -(360 * CEILING((ang - 180) / 360)).} else if (ang <= -180) {SET ang TO ANG -(360 * FLOOR((ang + 180) / 360)).}
until abs(ang - periLNG) < 0.1 and abs(deorb:orbit:periapsis - minSafeAltitude) < 50 {
    SET ETA TO ETA + (ang - periLNG)*3.
    if eta < 0 {set eta to eta + obt:period.}
    SET PROG TO PROG + max(-5,min(5,(minSafeAltitude-deorb:orbit:periapsis)/1500)).
    SET deorb:PROGRADE TO prog.
    SET deorb:ETA TO eta.
    SET bodyrot TO 360 * ((eta + deorb:orbit:period/2) / BODY:ROTATIONPERIOD).
    SET periLNG TO body:geopositionof(positionat(ship,time:seconds + eta + deorb:orbit:period/2)):lng.
    if (periLNG > 180) {SET periLNG TO periLNG -(360 * CEILING((periLNG - 180) / 360)).} else if (periLNG <= -180) {SET periLNG TO periLNG -(360 * FLOOR((periLNG + 180) / 360)).}
    set ang to targ:lng + bodyrot.
    if (ang > 180) {SET ang TO ang -(360 * CEILING((ang - 180) / 360)).} else if (ang <= -180) {SET ang TO ANG -(360 * FLOOR((ang + 180) / 360)).}
    if ang - periLNG > 180 {SET periLNG TO periLNG - 360.}
    if ang - periLNG < -180 {SET periLNG TO periLNG + 360.}
}
run Rybec_TIER3_donode.
wait 1.
SET periTIME to time:seconds + eta:periapsis.
SET periLAT TO body:geopositionof(positionat(ship,periTIME)):lat.
if abs(targ:lat - periLAT) > 0.2 {
    SET oldPe TO PERIAPSIS.
    SET prog TO 0.
    SET norm TO 0.
    SET nCorr TO node(time:seconds+eta:periapsis/2,0,norm,prog).
    ADD nCorr.
    until abs(targ:lat - periLAT) < 0.05 and abs(oldPe-nCorr:orbit:periapsis) < 50 {
        SET periLAT TO body:geopositionof(positionat(ship,periTIME)):lat.
        SET norm TO norm + max(-1,min(1,(targ:lat - periLAT)*2)).
        SET PROG TO PROG + max(-1,min(1,(oldPe-nCorr:orbit:periapsis)/1500)).
        SET nCorr:NORMAL TO norm.
        SET nCorr:PROGRADE TO prog.
    }
    run Rybec_TIER3_donode.
    wait 1.
}
SET acc TO SHIP:AVAILABLETHRUST/mass.
set bT to (VELOCITYAT(SHIP,ETA:PERIAPSIS):ORBIT:MAG/acc).
SET bS TO ETA:PERIAPSIS - bT * 0.5 - 15.
SET eta to TIME:SECONDS + bS.
SET prog TO 0.
SET deorb TO NODE(eta,0,0,prog).
add deorb.
until deorb:orbit:periapsis < -500 {
    SET PROG TO PROG - 3.
    SET deorb:PROGRADE TO prog.
    SET bT TO (prog/acc).
    SET deorb:ETA TO bS + bT/2.
}
run Rybec_TIER3_donode.
wait 0.1.
switch to 2.
GEAR ON.
SAS OFF.
SET hPID TO list(). hPID:add(0). hPID:add(0). hPID:add(0.3). hPID:add(0.1). hPID:add(0.3). hPID:add(0). hPID:add(0). hPID:add(time:seconds). hPID:add(-0.1). hPID:add(0.1). hPID:add(-0.5). hPID:add(1).
SET vPID TO list(). vPID:add(0). vPID:add(0). vPID:add(0.01). vPID:add(0.1). vPID:add(0.25). vPID:add(0). vPID:add(0). vPID:add(time:seconds). vPID:add(0). vPID:add(1). vPID:add(0). vPID:add(1).
SET oldTime to 0.
clearscreen.
print "runtime:". print "  hDist:". print " hrzErr:". print " vrtErr:". print " latErr:". print " totErr:". print "sterErr:". print "  throt:".
SET steer TO srfretrograde:vector.
LOCK STEERING TO steer.
SET hDist TO targ:ALTITUDEPOSITION(ALTITUDE):MAG.
until hDist < 40 and hPID[0] < 5 {
    SET dT TO time:seconds - oldTime.
    SET oldTime TO time:seconds.
    IF DT > 0 {
        SET hDist TO targ:ALTITUDEPOSITION(ALTITUDE):MAG.
        SET vDist to ALTITUDE - targ:TERRAINHEIGHT.
        SET altMod TO min(vDist,300).
        run Rybec_TIER3_predictImpact(targ:TERRAINHEIGHT + altMod).
        SET DIST TO targ:DISTANCE - impactGEO:DISTANCE.
        SET srfNorm TO VCRS(SRFPROGRADE:vector,UP:vector):NORMALIZED.
        SET hsVec TO VXCL(UP:VECTOR*VERTICALSPEED,-1*VELOCITY:SURFACE):normalized.
        SET normEm TO VDOT(targ:position,srfNorm).
        SET normE TO 0.0005 * min(1000,normEm).
        SET hSpd TO SURFACESPEED.
        SET dSpd TO max(0.1,hDist^0.58-2).
        SET vE TO (-1 * max(0.1,vDist)^0.4 - VERTICALSPEED) - max(0,VERTICALSPEED*15).
        SET vPID[0] TO vE.
        SET hPID[0] TO dist * -0.003.
        run Rybec_TIER3_pid(vPID).
        run Rybec_TIER3_pid(hPID).
        SET totalE TO abs(hPID[1]) + vPID[1] + normE.
        SET steervec TO UP:vector * vPID[1] + hsVec * (hPID[1] + 0.01) + srfNorm * normE.
        SET steer TO steervec:NORMALIZED.
        set steerErr to VANG(steervec:normalized,facing:vector).
        if steerErr > 45 {SET THROT TO 0.} ELSE {SET THROT TO totalE.}
        SET ship:control:MAINTHROTTLE TO THROT.
        SET SHIP:CONTROL:PILOTMAINTHROTTLE TO THROT.
        print round(dT,2)+ spaces at (9,0).
        print round(hDist,2)+ spaces at (9,1).
        print round(hPID[0],1)+ spaces at (9,2).
        print round(vE,1)+ spaces at (9,3).
        print round(normEm,2)+ spaces at (9,4).
        print round(DIST,2)+ spaces at (9,5).
        print round(steerErr,2)+ spaces at (9,6).
        print round(THROT,3)+ spaces at (9,7).
    }
    SET impactDRAW TO VECDRAWARGS(impactGEO:ALTITUDEPOSITION(impactALT+ALT:RADAR),impactGEO:ALTITUDEPOSITION(impactALT-ALT:RADAR) - impactGEO:ALTITUDEPOSITION(impactALT),CYAN,"I", 1, TRUE).
    wait 0.01.
}
list parts in partlist.
SET gearheight to 0.
for part in partlist{
    SET partY to part:POSITION:MAG*cos(vang(facing:forevector,part:POSITION)).
    SET gearheight TO min(gearheight,partY - 3).
}
GEAR ON. SAS OFF.
SET tPID TO list(). tPID:add(0). tPID:add(0). tPID:add(0.12). tPID:add(0.05). tPID:add(0.01). tPID:add(0). tPID:add(0). tPID:add(time:seconds). tPID:add(-0.1). tPID:add(1). tPID:add(0). tPID:add(1).
clearscreen.
print "runtime:". print "  Speed:". print "desSped:". print " posErr:". print "       :". print "sterErr:". print "  throt:".
SET steer TO srfretrograde:vector.
LOCK STEERING TO steer.
until STATUS = "LANDED" {
    SET dT TO time:seconds - oldTime.
    SET oldTime TO time:seconds.
    IF DT > 0 {
        run Rybec_TIER3_predictImpact(targ:TERRAINHEIGHT).
        SET dVS TO -1 * max(1,0.06 * (ALTITUDE - targ:TERRAINHEIGHT - gearheight + 20))^1.3.
        SET errDir TO (targ:POSITION - impactGEO:POSITION).
        SET throt TO round(errDir:mag,0)*0.00002 * (ALTITUDE - targ:TERRAINHEIGHT).
        SET spdErr TO dVS - VERTICALSPEED.
        SET steervec TO (up:vector * max(0.05,spdErr) ) + errDir:NORMALIZED * min(1,throt).
        SET steer TO steervec:normalized.
        set steerErr to VANG(steervec:normalized,facing:vector).
        if steerErr > 20 {SET THROT TO 0.}
        SET tPID[0] TO spdErr.
        run Rybec_TIER3_pid(tPID).
        SET T TO tPID[1] + throt.
        SET ship:control:MAINTHROTTLE TO T.
        SET SHIP:CONTROL:PILOTMAINTHROTTLE TO T.
        print round(dT,2)+ spaces at (9,0).
        print round(VERTICALSPEED,2)+ spaces at (9,1).
        print round(dVS,2)+ spaces at (9,2).
        print round(errDir:mag,1)+ spaces at (9,3).
        print round(steerErr,3)+ spaces at (9,5).
        print round(T,3)+ spaces at (9,6).
    }
    SET impactDRAW TO VECDRAWARGS(impactGEO:ALTITUDEPOSITION(impactALT+ALT:RADAR),impactGEO:ALTITUDEPOSITION(impactALT-ALT:RADAR) - impactGEO:ALTITUDEPOSITION(impactALT),CYAN,"I", 1, TRUE).
    wait 0.01.
}
UNLOCK STEERING.
SET ship:control:MAINTHROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS ON.
unset impactdraw.