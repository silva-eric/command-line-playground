# Each command of a multi-command pipeline runs in a subshell, so variable changes there do not survive
x=1
echo | x=2
echo "x=$x"
echo value | read v
echo "v=[${v-unset}]"
echo a | { read w; echo "inside the group: $w"; }
