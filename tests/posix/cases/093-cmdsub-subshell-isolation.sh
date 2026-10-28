# A command substitution runs in a subshell: variable changes, cd and exit inside it do not affect the shell
x=1
y=$(x=2; echo $x)
echo "x=$x y=$y"
mkdir d
z=$(cd d && touch inside && echo ok)
[ -f d/inside ] && [ ! -f inside ] && echo "cd stayed inside the substitution: $z"
w=$(echo before; exit 3; echo after)
echo "w=$w status=$?"
