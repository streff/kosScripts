
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
commslistDTS[0]:GETMODULE("ModuleRTAntenna"):SETFIELD("target","mission-control").
commslistDTS[0]:GETMODULE("ModuleRTAntenna"):DOEVENT("activate").
}.

