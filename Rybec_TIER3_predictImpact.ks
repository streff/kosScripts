DECLARE PARAMETER targAlt.
SET impactGEO TO LATLNG(0,0).
SET impactTIME TO 0.
SET impactLAT TO 0.
SET impactLNG TO 0.
SET impactALT TO targAlt.
SET PeR TO BODY:RADIUS+PERIAPSIS.
SET PeA TO PERIAPSIS.
SET PeT TO ETA:PERIAPSIS.
SET A TO OBT:SEMIMAJORAXIS.
SET Ecc TO OBT:ECCENTRICITY.
SET deg2Rad TO CONSTANT():PI / 180.
SET rad2Deg TO 180 / CONSTANT():PI.
SET i TO 1.
SET impactTheta TO -ARCCOS((PeR * (1 + Ecc) / (BODY:RADIUS + impactALT) - 1) / Ecc).
SET cosTheta TO COS(impactTheta).
SET cosE TO (Ecc + cosTheta) / (1.0 + Ecc * cosTheta).
SET radE TO ARCCOS(cosE).
SET M TO (radE * deg2Rad) - Ecc * SIN(radE).
SET timeOffset TO (SQRT(A^3 / BODY:MU) * M).
SET impactTIME TO PeT - timeOffset. 
SET impactPos TO BODY:GEOPOSITIONOF(POSITIONAT(ship,time:seconds+impactTIME)).
SET bodyrot TO 360 * (impactTIME / BODY:ROTATIONPERIOD).
SET ang TO impactPos:LNG - bodyrot.
if (ang > 180) {SET ang TO ang -(360 * CEILING((ang - 180) / 360)).} else if (ang <= -180) {SET ang TO ANG -(360 * FLOOR((ang + 180) / 360)).}
SET impactLNG TO ang.
SET impactLAT TO impactPos:LAT.
SET impactGEO TO LATLNG(impactLAT,impactLNG).