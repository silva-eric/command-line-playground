# The exit status of a pipeline is the status of its last command
false | true; echo $?
true | false; echo $?
true | (exit 3); echo $?
(exit 4) | true; echo $?
