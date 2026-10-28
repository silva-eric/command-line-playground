# An asynchronous command runs in a subshell: its assignments do not reach the shell
x=1
x=2 &
{ x=3; } &
wait
echo "x=$x"
