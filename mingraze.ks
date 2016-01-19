print "Copying files for Minmus Intercept & Orbit".
declare parameter mOrbit.


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


lock dirRadial to ship:obt:velocity:orbit:direction + r(0,90,0).
lock dirAantiradial to ship:obt:velocity:orbit:direction + r(0,-90,0).
lock dirNormal to ship:obt:velocity:orbit:direction + r(-90,0,0).
lock dirAntinormal to ship:obt:velocity:orbit:direction + r(90,0,0).

//set up science
//high above kerbin - immediately after burn
set gooList to ship:PARTSNAMED("GooExperiment").
set jrList to ship:PARTSNAMED("science.module").
set thermList to ship:PARTSNAMED("sensorThermometer").

set panelList2 to ship:partsdubbed("OX-4L 1x6 Photovoltaic Panels").

//enable lan/inc functions.. 
run set_inc_lan.

run launch(95000).

wait 5.
if panelList2:length > 0 {
for panel in panelList2 {
panel:GETMODULE("ModuleDeployableSolarPanel"):DOACTION("toggle panels",1).
}.
}.

//flatten out
clearscreen.
print "flatten out".
set tinc to 0.
set clan to ship:obt:lan.
set_inc_lan(tinc,clan).

clearscreen.
print "setting up injection burn".
set target to minmus.
set tinc to minmus:obt:inclination.
set clan to ship:obt:lan.
set tlan to minmus:obt:lan.
set_inc_lan(tinc,tlan).

wait 5.
if abs(ship:obt:inclination - minmus:obt:inclination) > 1 {set_inc_lan(tinc,tlan).}.
wait 5.
run circ_ap.

wait 5.
run streff_hohmann.
wait 5.

clearscreen.
print "Warping to target".
wait 5.
run warpTo(ETA:TRANSITION).
wait 5.
wait until body = body("Minmus").
run intercept(Minmus,mOrbit).
wait 5.

//SOI actions
//comms
//run commsDeploy.
//science
clearscreen.
print "Waiting for PE".
run warpTo(ETA:PERIAPSIS - 30).
wait until eta:periapsis < 20.

clearscreen.
print "Getting science".

if gooList:length > 0 {
SET P TO gooList[0].
SET M TO P:GETMODULE("ModuleScienceExperiment").
M:DEPLOY.
WAIT UNTIL M:HASDATA.
}.

if jrList:length > 0 {
SET P1 TO jrList[0].
SET M1 TO P1:GETMODULE("ModuleScienceExperiment").
M1:DEPLOY.
WAIT UNTIL M1:HASDATA.
}.

if thermList:length > 0 {
SET P3 TO thermList[0].
SET M3 TO P3:GETMODULE("ModuleScienceExperiment").
M3:DEPLOY.
WAIT UNTIL M3:HASDATA.
}.

wait 5.

clearscreen.
print "heading for home".
run grazeHome.


