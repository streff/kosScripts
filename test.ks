clearscreen.
SET hingeList to ship:PARTSDUBBED("Closed Powered Hinge").

for hinge in hingeList {
until hinge:getmodule("MUMECHTOGGLE"):GETFIELD("rotation") > 90{
hinge:GETMODULE("MUMECHTOGGLE"):doaction("move +", 1).
wait 0.25.
print hinge:getmodule("MUMECHTOGGLE"):GETFIELD("rotation").
}.
hinge:GETMODULE("MUMECHTOGGLE"):doaction("move +", 0).
}.

print hingelist[0]:getmodule("MUMECHTOGGLE"):ALLACTIONS.



