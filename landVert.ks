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
Set KdLatV to 14.00. //12
Set integralLatV to 0.
Set outMaxLatV to 0.03.
Set outMinLatV to -0.03.
Set KpVP to 500.
Set KiVP to 100.
Set KdVP to 200.
Set integralVP to 0.
Set outMaxVP to 45.
Set outMinVP to -45.
Set KpLngV to 1.0.
Set KiLngV to 0.0.
Set KdLngV to 14.00. //12
Set integralLngV to 0.
Set outMaxLngV to 0.03.
Set outMinLngV to -0.03.
Set KpVY to 500.
Set KiVY to 100.
Set KdVY to 200.
Set integralVY to 0.
Set outMaxVY to 45.
Set outMinVY to -45.

Wait 0.5.
Lock steering to steer.
Set starttime to missiontime.

Set desiredAltitude to 5000.
Set targetAltitude to 5000.


Set dt to 0.1.
Set previousA to ship:altitude.
Set previousV to ship:verticalspeed.
Set previousLat to latitude.
Set previousLng to longitude.
Set previousVelLat to 0.
Set previousVelLng to 0.

Until status = "LANDED" {
if stage:liquidfuel < 1 {stage.}.

	//if mAlt > 3000 {
	//set outMinAV to -100.
	//Set outMaxVP to 85.
	//Set outMinVP to -85.
	//Set outMaxVY to 85.
	//Set outMinVY to -85.
	//} else {
	//if groundspeed < 15 {
	//set outMinAV to -25.
	//Set outMaxVP to 25.
	//Set outMinVP to -25.
	//Set outMaxVY to 25.
	//Set outMinVY to -25.
	//}.
	//}.
	
	if TargHDist > 3000 {set desiredAltitude to min(TargHDist,5000).} else {set desiredAltitude to 500.}.
	
	if lights = false and TargHDist < 1000 {lights on.}.
	
	
	if  TargHDist < 5 and groundspeed < 2 {
	
		if (legs = false) {
			toggle legs.
			set desiredAltitude to 20.
			Set outMinAV to -10.

		}.
		
		if groundspeed < 5 and TargHDist < 10 {
			set desiredAltitude to 15.
			Set outMinAV to -15.
		}.	
		
		if groundspeed < 0.25 and TargHDist < 2 {
			set desiredAltitude to -3.
			Set outMinAV to -3.
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
	} else {
		Set steer to UP + r(max(-5, min(outVP, 5)), max(-5, min(outVY, 5)), 180).
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