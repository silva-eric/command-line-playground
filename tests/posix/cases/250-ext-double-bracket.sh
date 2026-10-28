# [[ ]] is a bash keyword; in dash it is only an unknown command name
# differs: dash says "[[: not found" (status 127); bash evaluates the test
[[ a = a ]] && echo "double brackets work"
echo "status $?"
