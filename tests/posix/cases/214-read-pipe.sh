# read at the end of a pipeline runs in a subshell; a { } group on the right side can use the values
echo "x y" | { read a b; echo "inside: $a-$b"; }
echo "x y" | read a2 b2
echo "outside: [${a2-unset}]"
