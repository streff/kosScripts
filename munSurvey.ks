print "Copying files for Mun Survey".

copy launch from 0.
copy streff_hohmann from 0.
copy donode from 0.
copy warpTo from 0.
copy intercept from 0.
copy land_noat from 0.
copy launch_noat from 0.
copy set_inc_lan from 0.
copy circ_ap from 0.
copy grazehome from 0.
copy commsDeploy from 0.


lock dirRadial to ship:obt:velocity:orbit:direction + r(0,90,0).
lock dirAantiradial to ship:obt:velocity:orbit:direction + r(0,-90,0).
lock dirNormal to ship:obt:velocity:orbit:direction + r(-90,0,0).
lock dirAntinormal to ship:obt:velocity:orbit:direction + r(90,0,0).

//enable lan/inc functions.. 
run set_inc_lan.

//get scanners listed.
set scanList to ship:partsnamed("SCANsat.Scanner").

run launch(110000).
wait 5.
clearscreen.
set target to mun.
run streff_hohmann.
wait 5.
run warpTo(ETA:TRANSITION).
wait 5.
run intercept(Mun,100000).

set clan to ship:obt:lan.
set_inc_lan(90,clan).
wait 5.
//correct from waypoint burn errors
if eta:apoapsis < eta:periapsis {
	if apoapsis < 90000 {lock steering to prograde. wait 5. lock throttle to 0.2. until apoapsis > 90000 {wait 0.5.}.}.
run circ_ap.
} else {
if periapsis < 90000 {lock steering to dirRadial. wait 5. lock throttle to 0.2. until periapsis > 90000 {wait 0.5.}.}.
run circ_ap.
}.

for part in scanList {
part:getModule("SCANsat"):doaction("start radar scan",1).
}.
clearscreen.
print "scanning...".
run commsDeploy.