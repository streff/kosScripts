DECLARE PARAMETER type, arg1, arg2.

SET mu TO BODY:MU.
SET rad TO BODY:RADIUS.
SET ap TO APOAPSIS.
SET pe TO PERIAPSIS.

if type = "circ"{
    if arg1 = "pe" {
        SET nAlt TO pe.
        SET nTime TO time:seconds + ETA:PERIAPSIS.
    } 
    if arg1 = "ap" {
        SET nAlt TO ap.
        SET nTime TO time:seconds + ETA:APOAPSIS.
    }
    SET nVel TO sqrt(mu*(2/(rad+nAlt)-1/(rad+nAlt)))-VELOCITYAT(SHIP,nTime):orbit:mag.
    ADD NODE(nTime,0,0,nVel).
} elseif type = "xfer" {
    //clearscreen.
    //set starttime to time:seconds.
    if arg1 = "moon"{
        if arg2:atm:exists{SET dAlt TO arg2:atm:height * 1.05.}
        else {SET dAlt TO 25000.}
        SET prog TO 0.
        SET eta TO time:seconds+150.
        SET xfer TO NODE(eta,0,0,prog).
        ADD xfer.
        SET eta TO xfer:ETA.
        
        until abs(arg2:altitude + arg2:radius * 1.5 - xfer:orbit:apoapsis) < 10000 {
            SET PROG TO PROG + max(-30,min(30,(arg2:altitude + arg2:radius * 1.5 - xfer:orbit:apoapsis)/300000)).
            SET xfer:PROGRADE TO prog.
        }
        until encounter <> "None" {
            SET ETA TO ETA + 10.
            if eta < 60 {SET eta TO eta + obt:period.}
            SET xfer:ETA TO eta.
            //wait 0.1.
        }
        SET oldDir TO 1.
        SET mul TO 3.
        until abs(encounter:periapsis-dAlt)<2000 {
            if encounter:periapsis-dAlt < 0 {SET errDir TO -1.}
            else {SET errDir TO 1.}
            if errDir <> oldDir {
                SET mul TO mul/2.
                //print "reversing".
            }
            SET oldDir to errDir.
            SET ETA TO ETA + errDir*mul.
            SET xfer:ETA TO eta.
            wait 0.01.
            if encounter = "None" {
                //print "Lost encounter!".
                until encounter <> "None" {
                    //SET ETA TO ETA + errDir*mul.
                    //SET xfer:ETA TO eta.
                    SET xfer:PROGRADE TO xfer:PROGRADE + 0.1.
                }
            }
        }
    }
    //print "Integrated in " + round(time:seconds - starttime,2) + " seconds.".
    if arg1 = "return"{
        
    }
    if arg1 = "planet"{
        //check that current body and target share a parent
        //something something ejection angles whatever
    }
}// elseif type = "sma"{ //Change altitude of opposing apsis
//    if arg1="ap"{
//        nAlt=arg2.
//        pAlt=semimajoraxis.
//        nRad=body:radius+apoapsis.
//        nTime=time:seconds+eta:apoapsis.
//    }.
//    SET va TO VELOCITYAT(SHIP,nTime):orbit:mag.
//    SET v2
//    ADD NODE(nTime,0,0,nVel).
//}