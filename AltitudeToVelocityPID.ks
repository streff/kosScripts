Declare parameter targetAltitude.
Set errorAV to targetAltitude - mAlt.
Set integralAV to integralAV + (errorAV * dt).
If (integralAV * KiAV ) > outMaxAV{
	Set integralAV to outMaxAV / KiAV.
}.
If (integralAV * KiAV) < outMinAV{
	Set integralAV to outMinAV / KiAV.
}.
Set derivativeAV to (mAlt - previousA) / dt.
Set previousA to mAlt.
Set outAV to ((KpAV * errorAV) + (KiAV * integralAV) + (KdAV * derivativeAV)).
If (outAV > outMaxAV){
	Set outAV to outMaxAV.
}.
If (outAV < outMinAV){
	Set outAV to outMinAV.
}.