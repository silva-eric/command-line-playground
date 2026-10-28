# ( ) runs commands in a subshell: variables and functions set there do not survive
x=1
(x=2; echo "inside: $x")
echo "outside: $x"
(f() { echo "f"; })
f 2>/dev/null || echo "f is not defined outside"
