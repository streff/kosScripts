//return from orbit
run set_inc_lan.
if body = body("Mun") or body = body("Minmus") {
set mysteer to prograde.
SET g TO BODY:MU / BODY:RADIUS^2.


lock dirRadial to ship:obt:velocity:orbit:direction + r(0,90,0).
lock dirAantiradial to ship:obt:velocity:orbit:direction + r(0,-90,0).
lock dirNormal to ship:obt:velocity:orbit:direction + r(-90,0,0).
lock dirAntinormal to ship:obt:velocity:orbit:direction + r(90,0,0).
lock STEERING to mysteer.

//escape the mun - brute numbers - 807.08 m/s on an opposite vector from the muns orbital vector around kerbin

set tinc to 0.
set clan to ship:obt:lan.
set_inc_lan(tinc,clan).


set myVang to VANG(ship:velocity:orbit, (V(0,0,0) - body:orbit:velocity:orbit)).


set warp to 3.
until myVang < 10 {
clearscreen.
print "me: " + ship:velocity:orbit.
print "body: " + body:orbit:velocity:orbit.
print "vang: " + VANG(ship:velocity:orbit, (V(0,0,0) - body:orbit:velocity:orbit)).
set myVang to VANG(ship:velocity:orbit, (V(0,0,0) - body:orbit:velocity:orbit)).
wait 0.5.
}.

set warp to 0.
lock throttle to 0.

//calculate deltaV required for transfer to target altitude
set h1 to r+((ship:apoapsis+ship:periapsis)/2).
set h2 to body:soiradius + 1000.
set ra to r +(periapsis+apoapsis)/2.
set ps to V(0,0,0) - body:position.
set smas to ps:mag.
set vom to velocity:orbit:mag.
set va to sqrt( vom^2 - 2*body:mu*(1/ra - 1/(r + altitude))).
set smah to (ra + h2)/2.
set deltaV1 to sqrt(va^2 - body:mu * (1/smah - 1/smas)).
set escapeVel to (2*deltaV1) - va.


SET orbitNode to NODE( TIME:SECONDS+15, 0, 0, escapeVel).
add orbitNode.
run donode.

remove orbitNode.
//adjust next PE
if orbit:hasnextpatch = true {
if orbit:nextpatch:periapsis < 20000 {
lock steering to retrograde.
 wait 4.
 lock throttle to 0.3.
 until orbit:nextpatch:periapsis > 20000 {wait 0.1.}.
lock throttle to 0.
}.
if orbit:nextpatch:periapsis > 100000 {
lock steering to prograde.
 wait 4.
 lock throttle to 0.3.
 until orbit:nextpatch:periapsis > 20000 {wait 0.1.}.
lock throttle to 0.
}.
}.

//transit to kerbin

clearscreen.
print "Waiting for SOI transition".
wait 5.
run warpTo(ETA:TRANSITION).
wait until body = body("Kerbin").
}.
print "pointing retrograde".
set mySteer to retrograde.
lock steering to retrograde.
//wait until align < 0.2.
wait 10.
if periapsis > 70000 {
print "burning for low PE".
until periapsis < 40000 {
lock throttle to 0.8.
wait 0.2.
}.
}.
if periapsis < 20000 {lock steering to dirRadial. wait 2. lock throttle to 0.3. until periapsis > 20000 {wait 0.1.}. lock throttle to 0.}.
lock throttle to 0.
print "warping to PE".
wait 2.
set wtime to 2 * (ETA:Periapsis / 3).
run warpto(wtime).
set mySteer to retrograde.
lock steering to retrograde.
wait 2.
//wait until align < 0.2.
toggle BRAKES.
print "descending".
wait until altitude < 1800.
toggle ABORT.

print "chutes away".