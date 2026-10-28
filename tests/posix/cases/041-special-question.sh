# $? is the exit status of the most recent pipeline
true; echo $?
false; echo $?
(exit 7); echo $?
! true; echo $?
x=1; echo $?
nosuchcommand_xyz 2>/dev/null; echo $?
false; echo "$? $?"
