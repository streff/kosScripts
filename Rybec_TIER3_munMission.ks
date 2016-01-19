SET TERMINAL:WIDTH TO 80.
SET TERMINAL:HEIGHT TO 24.
clearscreen.
SET startmass TO mass.
print "-------------------------------".
print "|   Rybec's Munar Mission     |".
print "|   Start mass: " + round(mass,2) + " tons". print "|" at (30,2).
print "|   Mission begins in   s.    |".
print "-------------------------------".
set i to 5.
until i = 0 {print i at (22,3). wait 1. SET i TO i-1.}
when APOAPSIS > 60000 THEN {
    TOGGLE AG1.
}
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
STAGE.
for eng in ship:partsnamed("nuclearEngine") {eng:SHUTDOWN().}
run Rybec_TIER3_launch(80000,0).
run Rybec_TIER3_calcnode("xfer","moon",mun).
run Rybec_TIER3_donode.
run Rybec_TIER3_warpto(time:seconds+ETA:TRANSITION).
print "Waiting 10s.".
wait 10.
run Rybec_TIER3_calcnode("circ","pe",0).
run Rybec_TIER3_donode.
if obt:eccentricity > 0.002 {run Rybec_TIER3_calcnode("circ","pe",0). run Rybec_TIER3_donode.}
//set goal to latlng(0,0).//testing
//set goal to latlng(8,172).//tier 2
set goal to latlng(2.46373581886292,81.5251212255859).//tier 3
switch to 2.
run Rybec_TIER3_autoland(goal).

clearscreen.
print "Landed! Prepare to de-sas in: ".
set i to 10.
until i = 0 {print i + " " at (30,0). wait 1. SET i TO i-1.}
clearscreen.
SAS OFF.
print " #  # #    ##  #  ##    ### # # ###    ##  #   ##   ###  ##    #  ### ### #".
print "# # # #   #   # # # #    #  # # #     #   # # #      #  #     # # #   #   #".
print "# # ###   # # # # # #    #  ### ##     #  ###  #     #   #    # # ##  ##  #".
print "# # # #   # # # # # #    #  # # #       # # #   #    #    #   # # #   #    ".
print " #  # #    ##  #  ##     #  # # ###   ##  # # ##    ### ##     #  #   #   #".
wait 5.
clearscreen.
print "-------------------------------".
print "|  Mission Results(if alive): |".
print "|   Start mass: " + round(startmass,2) + " tons". print "|" at (30,2).
print "|     End mass: " + round(mass,2) + " tons". print "|" at (30,3).
print "| Payload Frac: " + round(100*(mass/startmass),4) + " %". print "|" at (30,4).
print "| Distance Err: " + round((ship:geoposition:position - goal:position):mag,4). print "|" at (30,5).
print "|Distance based on ship geopos|".
print "-------------------------------".