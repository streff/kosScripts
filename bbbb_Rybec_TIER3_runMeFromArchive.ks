SHIP:PARTSTAGGED("mainComp")[0]:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
//delete boot.
switch to 0.
copy Rybec_TIER3_munMission.ks to 1.
copy Rybec_TIER3_launch.ks to 1.
copy Rybec_TIER3_calcnode.ksm to 1.
copy Rybec_TIER3_warpTo.ks to 1.
copy Rybec_TIER3_doNode.ks to 1.

copy Rybec_TIER3_autoland.ks to 2.
copy Rybec_TIER3_predictImpact.ks to 2.
copy Rybec_TIER3_PID.ks to 2.
switch to 1.
run Rybec_TIER3_munMission.

