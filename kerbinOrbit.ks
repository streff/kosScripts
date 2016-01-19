declare parameter degFromKSC.

copy launch from 0.
copy streff_obt_hohmann from 0.
copy donode from 0.
copy warpTo from 0.
copy intercept from 0.
copy set_inc_lan from 0.
copy circ_ap from 0.
copy grazehome from 0.

set pad to latlng(latitude, longitude).

lock dirRadial to ship:obt:velocity:orbit:direction + r(0,90,0).
lock dirAantiradial to ship:obt:velocity:orbit:direction + r(0,-90,0).
lock dirNormal to ship:obt:velocity:orbit:direction + r(-90,0,0).
lock dirAntinormal to ship:obt:velocity:orbit:direction + r(90,0,0).

run set_inc_lan.

run launch(100000).

wait 5.

run circ_ap.

set clan to ship:obt:lan.
set_inc_lan(0,clan).

wait 2.
run circ_ap.
wait 2.
run streff_obt_hohmann(pad:lng + degFromKSC).
wait 2.
run circ_ap.
set commslist16 to ship:partsdubbed("Communotron 16").
print "Attempting Short range connection...".

if commslist16:length > 0 {

for comm in commslist16{
comm:GETMODULE("ModuleRTAntenna"):DOEVENT("activate").
}.
}.

set commslistDTS to ship:partsdubbed("Comms DTS-M1").
print "Attempting Mid range connection...".

if commslistDTS:length > 0 {
commslistDTS[0]:GETMODULE("ModuleRTAntenna"):DOEVENT("activate").
commslistDTS[0]:GETMODULE("ModuleRTAntenna"):SETFIELD("target","mission-control").
}.

