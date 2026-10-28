# The status of { } and ( ) is that of their last command
{ true; false; }; echo $?
{ false; true; }; echo $?
(false; true); echo $?
(true; false); echo $?
