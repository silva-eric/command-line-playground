# set -e: the shell exits as soon as a simple command or pipeline fails; a pipeline's status is its last command's
set -e
echo before
false | true; echo "false | true is fine"
true | false
echo never
