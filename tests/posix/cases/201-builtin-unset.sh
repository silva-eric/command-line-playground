# unset removes variables (also with -v) and functions (-f); unsetting a name that is not set is not an error
x=1; unset x; echo "x=[${x-unset}]"
y=2; unset -v y; echo "y=[${y-unset}]"
f() { echo f; }; unset -f f; f 2>/dev/null || echo "f removed"
unset nothing_here; echo "status $?"
a=1 b=2; unset a b; echo "[${a-unset}] [${b-unset}]"
v=var; v() { echo "function v survives"; }; unset v; v; echo "[${v-unset}]"
