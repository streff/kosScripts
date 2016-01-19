DECLARE PARAMETER arg.
SET dT TO time:seconds - arg[7].
if dT > 0{
    SET arg[5] TO (arg[5] + arg[0]*arg[3]*dT).
    SET D TO (arg[0] - arg[6]) / dT.
    SET arg[5] TO max(arg[8],min(arg[9],arg[5])).
    SET arg[1] TO max(arg[10],min(arg[11],arg[0] * arg[2] + arg[5] + D * arg[4])).
    SET arg[6] TO arg[0].
    SET arg[7] TO time:seconds.
}