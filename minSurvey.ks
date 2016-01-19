print "Copying files for Mun Survey".

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
copy commsDeploy from 0.


lock dirRadial to ship:obt:velocity:orbit:direction + r(0,90,0).
lock dirAantiradial to ship:obt:velocity:orbit:direction + r(0,-90,0).
lock dirNormal to ship:obt:velocity:orbit:direction + r(-90,0,0).
lock dirAntinormal to ship:obt:velocity:orbit:direction + r(90,0,0).

//enable lan/inc functions.. 
function align_orbital_plane{
	parameter other.

	local my_r is (body:position-ship:position).
	local my_normal is VCRS(obt:velocity:orbit,my_r).
	
	local other_r is (body:position-other:position).
	local other_normal is VCRS(other:obt:velocity:orbit,other_r).

	local target_place is VCRS(my_normal,other_normal):normalized.
	local pe_place is positionat(ship,time:seconds+eta:periapsis)-body:position.
	local my_place is ship:position-body:position.

	local vel_at_pe is velocityat(ship,time:seconds+eta:periapsis):orbit.

	local true_anomaly is VANG(target_place,pe_place).
	if VDOT(target_place,vel_at_pe)<0{
		set true_anomaly to -true_anomaly.
	}
	local true_anomaly_of_me is VANG(my_place,pe_place).
	if VDOT(my_place,vel_at_pe)<0{
		set true_anomaly_of_me to -true_anomaly_of_me.
	}
	local diff is mod(true_anomaly-true_anomaly_of_me+360,360).
	if diff>180{
		set true_anomaly to true_anomaly-180.
		// switch descending to ascending node or vice versa to closer one
	}
	local t is time_to_true_anomaly(obt,true_anomaly).

	local inc is VANG(my_normal,other_normal).
	local vel_at_t is velocityat(ship,time:seconds+t):orbit.
	if VDOT(other_normal,vel_at_t)>0{
		set inc to -inc.
	}

	return change_inclination(time:seconds+t,inc).
}

// This function rotates ship's orbit by burning normally at specified time
// BY given amomunt (not TO angle, but BY angle).
function change_inclination{
	parameter
		t,
		ang.
	
	local r is (body:position-positionat(ship,t)).
	local actual_vel is velocityat(ship,t):orbit.
	local normal_vel is VCRS(actual_vel,r):normalized*actual_vel:mag.
	return make_node_t_deltav(t,actual_vel*(cos(ang)-1)+normal_vel*sin(ang)).
}

function time_to_true_anomaly{
	parameter
		orb,
		a2.
	
	local e is orb:eccentricity.
	local a1 is orb:trueanomaly. // the current one
	local f is sqrt((1-e)/(1+e)).

	local e1 is 2*arctan(f*tan(a1/2)).
	local e2 is 2*arctan(f*tan(a2/2)).
	// e1 and e2 are eccentric anomalies at these times in degrees
	local m1 is constant():pi/180*e1-e*sin(e1).
	local m2 is constant():pi/180*e2-e*sin(e2).
	// m1 and m2 are mean anomalies at these times in radians
	local n is 2*constant():pi/orb:period.
	// n is mean angular velocity
	local t1 is m1/n.
	local t2 is m2/n.
	// t1 and t2 are times with regard to some, non-disclosed epoch,
	// at which orbitable will be at true anomaly a1 or a2 respectively
	local diff is t2-t1.
	if diff<0{ // ETA must be positive, so switch to next orbit
		set diff to orb:period+diff.
	}
	else if diff>orb:period{ // we can do one full orbit less
		set diff to diff-orb:period.
	}
	return diff.
}

function make_node_t_deltav{
	parameter
		t,
		dv.
	
	local pro_unit is velocityat(ship,t):orbit:normalized.
	local rad_unit is -VXCL(pro_unit,body:position-positionat(ship,t))
		:normalized.
	local nor_unit is VCRS(pro_unit,rad_unit).
	return node(t,rad_unit*dv,nor_unit*dv,pro_unit*dv).
}

//get scanners listed.
set scanList to ship:partsnamed("SCANsat.Scanner").

//launch
run launch(110000).
wait 5.
clearscreen.

set target to minmus.

print "aligning orbital plane to " + target.
set HohmAlignNode to align_orbital_plane(Minmus).
add HohmAlignNode.
run donode.
remove HohmAlignNode.

wait 5.

run streff_hohmann.
wait 5.

run warpTo(ETA:apoapsis).
wait 5.
run intercept(target,60000).


//correct from waypoint burn errors
if eta:apoapsis < eta:periapsis {
	if apoapsis < 55000 {lock steering to prograde. wait 5. lock throttle to 0.2. until apoapsis > 55000 {wait 0.5.}.}.
run circ_ap.
} else {
if periapsis < 10000 {lock steering to ship:obt:velocity:orbit:direction + r(0,90,0). wait 5. lock throttle to 0.2. until periapsis > 10000 {wait 0.5.}.}.
run circ_ap.
}.

set cur_inc to ship:obt:inclination.
set orbAlignNode to change_inclination(20, 90 - cur_inc).
add orbAlignNode.
run donode.
remove orbAlignNode.

for part in scanList {
part:getModule("SCANsat"):doaction("start radar scan",1).
}.
clearscreen.
print "scanning...".
run commsDeploy.