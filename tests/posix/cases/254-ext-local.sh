# local is not in POSIX, but dash and bash both have it: inside a function it makes a variable local
f() { local v=inner; echo "inside: $v"; }
v=outer; f; echo "outside: $v"
