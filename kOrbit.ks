print "Copying files for Kerbin Orbit and Return".
declare parameter orbAlt.


copy launch.ks from 0.
copy donode.ks from 0.
copy warpTo.ks from 0.



run launch(orbAlt).

wait 5.

clearscreen.
print "................................................".
print "StreffX Cosmic Tourism team welcomes you to space.".
print "................................................".

wait 5.

print "Pointing nose Retrograde...".
lock steering to retrograde.

print "Burn for DeOrbit.".

wait 5.

lock throttle to 0.5.

wait until periapsis < 40000.

lock throttle to 0.
wait 2.
print "deOrbit set".
wait 2.

print "Ditching remaining tanks....".
wait 2.
toggle BRAKES.

wait until alt:radar < 2000.
print "chutes on... fingers crossed.".
toggle ABORT.
unlock all.


//end program