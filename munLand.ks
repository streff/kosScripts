declare parameter padTrgLat, padTrgLng.
print "Copying files for Mun landing & return".

copy launch from 0.
copy streff_hohmann from 0.
copy donode from 0.
copy warpTo from 0.
copy intercept from 0.
copy land_noat_spot from 0.
copy launch_noat from 0.
copy set_inc_lan from 0.
copy grazehome from 0.
rename grazehome to boot.
copy grazehome from 0.

Copy landvert from 0.
Copy AltitudeToVelocityPID from 0.
Copy VelocityToThrustPID from 0.
Copy LatitudeToVelocityPID from 0.
Copy LongitudeToVelocityPID from 0.
Copy LatVelocityToPitchPID from 0.
Copy LngVelocityToYawPID from 0.

run launch(98000).
wait 5.
set panelList2 to ship:partsdubbed("SP-W 3x2 Photovoltaic Panels").
for panel in panelList2{
panel:GETMODULE("ModuleDeployableSolarPanel"):DOACTION("toggle panels",1).
}.
wait 5.
set target to mun.
run streff_hohmann.
wait 5.
run warpTo(ETA:TRANSITION).
wait 5.
run intercept(Mun,15000).
wait 5.
set panelList1 to ship:partsdubbed("SP-L 1x6 Photovoltaic Panels").
for panel in panelList1{
panel:GETMODULE("ModuleDeployableSolarPanel"):DOACTION("toggle panels",1).
}.

//set inclination to pick rough landing spot
run set_inc_lan.
set clan to ship:obt:lan.
if abs(ship:obt:inclination) > 5 {
set_inc_lan(0,clan).
}.

wait 10.
run land_noat_spot(padTrgLat, padTrgLng).
lights on.

wait 2.

set gooList to ship:PARTSNAMED("GooExperiment").
set jrList to ship:PARTSNAMED("science.module").
set thermList to ship:PARTSNAMED("sensorThermometer").

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
print "returning home".
wait 2.

run launch_noat.
lights off.
run grazehome.



