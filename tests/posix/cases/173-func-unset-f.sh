# unset -f removes a function; a variable of the same name is separate and stays
f() { echo "function f"; }
f=variable
f
echo "$f"
unset -f f
f 2>/dev/null || echo "function gone, status $?"
echo "variable still: $f"
