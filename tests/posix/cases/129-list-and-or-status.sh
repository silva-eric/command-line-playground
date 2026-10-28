# The status of an AND-OR list is that of the last command that actually ran
false && true; echo $?
true || false; echo $?
false || false; echo $?
true && (exit 3); echo $?
(exit 2) || true; echo $?
