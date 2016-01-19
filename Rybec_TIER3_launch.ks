// Launch to a circular orbit with the altitude and inclination of your choice.
// Follows ascent profile optimized for N.E.A.R. Works fine with FAR so long as your TWR isn't too low
// TODO: Develop generic atmo ascent profile generator; pitch related to vertical speed and atm pressure?

//Variable init
//TODO: Accept parameters for LAN?, Target intercept?
DECLARE PARAMETER Ap, Inc.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SET spaces TO "          ".

if inc >= abs(latitude){
    SET azimuth TO arcsin(cos(inc)/cos(lattitude)).
    //Add bodyrot compensation here.
} else {SET azimuth TO 90.}


IF BODY:ATM:EXISTS = TRUE {
    SET ApMax TO 50.
    SET ApMin TO 50.
    SET altStart TO 100.
    SET altEnd TO BODY:ATM:HEIGHT * 0.9.
    SET endAlt TO BODY:ATM:HEIGHT + 150.
    SET dTWR TO 2.
} ELSE {
    SET ApMax TO 3.
    SET ApMin TO 5.
     SET altStart TO 10.
    SET altEnd TO 1000.
    SET endAlt TO 0.
    SET dTWR TO 1000.
}
CLEARSCREEN.
PRINT "Launching to " + (Ap/1000) + "km orbit".
PRINT "with an inclination of " + Inc + " degrees.".

//heading = 90-desired inclination. This is not accurate.
//TODO: Take body rotation speed into account and adjust launch heading accordingly
SET HDG TO AZIMUTH.
SET PITCH TO 90.
SET MECO TO 0.

WHEN STATUS <> "LANDED" and STATUS <> "PRELAUNCH" THEN {
    GEAR OFF.
}

WHEN APOAPSIS >= Ap + ApMax and MECO = 0  THEN {
    SET THRT TO 0.
    SET MECO TO 1.
    PRINT "Main engine cutoff" at (0,7).
    if ALTITUDE < endAlt {PRESERVE.}
}

WHEN APOAPSIS <= Ap - ApMin AND MECO = 1 THEN {
    SET MECO TO 0.
    PRINT "Burning" + spaces + spaces at (0,7).
    if ALTITUDE < endAlt {PRESERVE.}
}


SET countdown TO 5.
PRINT "Counting down:".
UNTIL countdown = 0 {
    PRINT countdown AT (15,2).
    SET countdown TO countdown - 1.
    WAIT 1.
}
SET THRT TO 1.
LOCK THROTTLE TO THRT.
SET SAS TO FALSE.
PRINT "Launch!          " AT (0,2).
PRINT "Current apoapsis:".
PRINT "Current Ap error:".
PRINT "Current heading :".
PRINT "Current pitch   :".
PRINT "Burning".
LOCK STEERING TO HEADING(HDG,PITCH).

UNTIL (ALTITUDE > endAlt and (MECO = 1 or APOAPSIS >= Ap - ApMin)){
    SET ALTPER TO MIN(1,MAX(0,ALT:RADAR-altStart)/(altEnd-altStart)).
    SET PITCH TO 90*(1-ALTPER^(0.6-(ALTPER/2))).
    SET GRAV TO mass*BODY:MU/BODY:RADIUS^2.
    SET apErr TO ((Ap - APOAPSIS) / 4000)+0.05.
    SET mTWR TO SHIP:AVAILABLETHRUST / GRAV.
    IF mTWR = 0 SET mTWR TO 10.
    IF MECO = 0 SET THRT TO max(0,min(dTWR/mTWR,apErr)).
    PRINT round(APOAPSIS) + spaces AT (18,3).
    PRINT round(Ap - APOAPSIS,0) + spaces AT (18,4).
    PRINT HDG + spaces AT (18,5).
    PRINT round(PITCH,1) + spaces AT (18,6).
    SET numOut TO 0.
    LIST ENGINES IN ENGLIST.
    IF STAGE:READY AND STAGE:NUMBER > 0 {
        FOR eng IN englist {if eng:flameout {SET numOut TO numOut + 1.}}
        if (numOut > 0 or maxthrust = 0) {stage.}
    }
    WAIT 0.2.
}
SET thrt TO 0.
SET WARPMODE TO "RAILS".
SET warp TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
wait 0.2.
run Rybec_TIER3_calcNode("circ","ap",0).
run Rybec_TIER3_doNode.