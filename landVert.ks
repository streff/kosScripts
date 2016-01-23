//Set pad to latlng(latitude,longitude).
declare parameter pad.
set scaleLength to 360/((2*body:radius)*3.14).
Lock throttle to 0.
Set steer to UP + r(0,0,180).
Lock mAlt to alt:radar - 4.

Set coordinates to pad.
Set maxheight to mAlt.
Lock TargHDist to sqrt(((coordinates:lat - latitude)^2) + ((coordinates:lng - longitude)^2))/scaleLength.
Set maxdiversion to TargHDist.
Set KpAV to 0.300.
Set KiAV to 0.000.
Set KdAV to 0.050.
Set integralAV to 0.
Set outMaxAV to 25.
Set outMinAV to -25.
Set KpVT to 0.100.
Set KiVT to 0.200.
Set KdVT to 0.005.
Set integralVT to 0.
Set outMaxVT to 1.
Set outMinVT to 0.01.
Set KpLatV to 1.0.
Set KiLatV to 0.0.
Set KdLatV to 12.00.
Set integralLatV to 0.
Set outMaxLatV to 0.05.
Set outMinLatV to -0.05.
Set KpVP to 500.
Set KiVP to 100.
Set KdVP to 200.
Set integralVP to 0.
Set outMaxVP to 25.
Set outMinVP to -25.
Set KpLngV to 1.0.
Set KiLngV to 0.0.
Set KdLngV to 12.00.
Set integralLngV to 0.
Set outMaxLngV to 0.05.
Set outMinLngV to -0.05.
Set KpVY to 500.
Set KiVY to 100.
Set KdVY to 200.
Set integralVY to 0.
Set outMaxVY to 25.
Set outMinVY to -25.
Set waypoint1 to latlng(pad:lat, pad:lng).

Wait 0.5.
Lock steering to steer.
Set starttime to missiontime.

Set desiredAltitude to 100.
Set targetAltitude to 0.


Set dt to 0.1.
Set previousA to ship:altitude.
Set previousV to ship:verticalspeed.
Set previousLat to latitude.
Set previousLng to longitude.
Set previousVelLat to 0.
Set previousVelLng to 0.

Until status = "LANDED" {
if stage:liquidfuel < 1 {stage.}.

	if mAlt > 3000 {
	set outMinAV to -100.
	} else {
	set outMinAV to -25.
	}.
	if TargHDist > 10000 {set desiredAltitude to 4000.} else {set desiredAltitude to 100.}.
	
	if lights = false and TargHDist < 2000 {lights on.}.
	
	
	if  TargHDist < 5 and groundspeed < 2 {
	
		if (legs = false) {
			toggle legs.
		}.
				
		if groundspeed < 1 and TargHDist < 5 {
			set desiredAltitude to -3. Set outMinAV to -5.
		}.	
		
	}.
	
	Set velLat to (latitude - previousLat)/dt.
	Set velLng to (longitude - previousLng)/dt.
	Set targetAltitude to max(desiredAltitude, targetAltitude - 10).
	Run AltitudeToVelocityPID(targetAltitude).
	Set desiredVelocity to outAV.
	Run VelocityToThrustPID(desiredVelocity).
	Lock throttle to outVT.
	Run LatitudeToVelocityPID.
	Run LongitudeToVelocityPID.
	
	
	Set desiredLatVelocity to outLatV.
	Set desiredLngVelocity to outLngV.
	

	Run LatVelocityToPitchPID(desiredLatVelocity).
	Run LngVelocityToYawPID(desiredLngVelocity).
	If mAlt > 5 {
		Set steer to UP + r(outVP, outVY, 180).
	}.
	if mAlt > 3000 {
		Set outMaxVP to 60.
		Set outMinVP to -60.
		Set outMaxVY to 60.
		Set outMinVY to -60.
	} else {
		Set outMaxVP to 30.
		Set outMinVP to -30.
		Set outMaxVY to 30.
		Set outMinVY to -30.
	}.
		

	
	Set previousA to mAlt.
	Set previousV to verticalspeed.
	Set previousVelLat to velLat.
	Set previousVelLng to velLng.
	Set maxdiversion to TargHDist.
	Wait dt.


	clearscreen.
	print "=======================".
	print "LAT: " + latitude.
	print "VLAT: " + velLat.
	print "LON: " + longitude.
	print "VLON: " + velLng.
	print "Distance to target: " + TargHDist.
	print "Target: " + coordinates.
	print "desiredAltitude: " + desiredAltitude.
	print "alt: " + alt:radar.
	print "GrndSpd: " + groundspeed.
	print "=======================".
	
}.
lock throttle to 0.
unlock all.

wait 5.