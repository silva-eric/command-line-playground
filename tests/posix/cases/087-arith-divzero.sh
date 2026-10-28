# Division or remainder by zero is an error: a message on stderr and the (sub)shell exits
# differs: the subshell exits with status 2 in dash and 1 in bash (messages differ too)
(echo $((1 / 0)); echo not reached)
echo "status $?"
(echo $((5 % 0)); echo not reached)
echo "status $?"
x=0; (echo $((10 / x)))
echo "status $?"
