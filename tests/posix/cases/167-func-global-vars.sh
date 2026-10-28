# Variables assigned inside a function are global (POSIX has no local variables)
f() { x=inside; y=$1; }
x=outside
f arg
echo "x=$x y=$y"
