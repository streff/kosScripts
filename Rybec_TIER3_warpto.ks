declare parameter t1.
set rt to t1 - time:seconds.
until rt < 5 {
    set rt to t1 - time:seconds.
    set wp to 0.
    if rt > 5      {set wp to 1.}
    if rt > 20     {set wp to 2.}
    if rt > 50     {set wp to 3.}
    if rt > 200    {set wp to 4.}
    if rt > 2000   {set wp to 5.}
    if rt > 20000  {set wp to 6.}
    if rt > 200000 {set wp to 7.}
    set warp to wp.
}
