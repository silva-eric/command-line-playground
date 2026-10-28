# ((expr)) is a bash arithmetic command; dash reads it as two nested subshells running a command named x
# differs: dash tries to run a command 'x' (not found, status 127); bash evaluates the expression and sets x
((x = 1 + 2))
echo "status $? x=[${x-unset}]"
