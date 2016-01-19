print "Copying files for Kerbin Survey".

copy launch from 0.
copy streff_hohmann from 0.
copy donode from 0.
copy warpTo from 0.
copy intercept from 0.
copy land_noat from 0.
copy launch_noat from 0.
copy set_inc_lan from 0.
copy grazehome from 0.

Copy landvert from 0.
Copy AltitudeToVelocityPID from 0.
Copy VelocityToThrustPID from 0.
Copy LatitudeToVelocityPID from 0.
Copy LongitudeToVelocityPID from 0.
Copy LatVelocityToPitchPID from 0.
Copy LngVelocityToYawPID from 0.

//enable lan/inc functions.. 
run set_inc_lan.

//get scanners listed.
set scanList to ship:partsnamed("SCANsat.Scanner").

run launch(110000).
wait 5.
clearscreen.

set clan to ship:obt:lan.
set_inc_lan(85,clan).
wait 5.


for part in scanList {
part:getModule("SCANsat"):doaction("start radar scan",1).
}.
clearscreen.
print "scanning...".
