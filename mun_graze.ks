print "Copying files for Mun Intercept & Orbit".
declare parameter mOrbit.


copy launch.ks from 0.
copy streff_hohmann.ks from 0.
copy donode.ks from 0.
copy warpTo.ks from 0.
copy intercept.ks from 0.
copy grazehome from 0.
rename grazehome to boot.
copy grazehome from 0.
copy set_inc_lan from 0.
run set_inc_lan.
run launch(95000).

wait 5.

set panelList2 to ship:partsdubbed("OX-4L 1x6 Photovoltaic Panels").
for panel in panelList2{
panel:GETMODULE("ModuleDeployableSolarPanel"):DOACTION("toggle panels",1).
}.

//science
//high above kerbin - immediately after burn
set gooList to ship:PARTSNAMED("GooExperiment").
set jrList to ship:PARTSNAMED("science.module").
set thermList to ship:PARTSNAMED("sensorThermometer").



clearscreen.
print "setting up injection burn".
set target to mun.
run streff_hohmann.
wait 5.

clearscreen.
print "Warping to target".
wait 5.
run warpTo(ETA:TRANSITION).
wait 5.
wait until body = body("Mun").
run intercept(Mun,mOrbit).
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

if gooList:length > 1 {
SET P TO gooList[1].
SET M TO P:GETMODULE("ModuleScienceExperiment").
M:DEPLOY.
WAIT UNTIL M:HASDATA.
}.

if jrList:length > 1 {
SET P1 TO jrList[1].
SET M1 TO P1:GETMODULE("ModuleScienceExperiment").
M1:DEPLOY.
WAIT UNTIL M1:HASDATA.
}.

if thermList:length > 1 {
SET P3 TO thermList[1].
SET M3 TO P3:GETMODULE("ModuleScienceExperiment").
M3:DEPLOY.
WAIT UNTIL M3:HASDATA.
}.

wait 5.
set tinc to 0.
set tlan to ship:obt:lan.
set_inc_lan(tinc,tlan).
clearscreen.
print "heading for home".
run grazeHome.


