# exec with a command replaces the shell (a subshell here); exec with only redirections changes the shell's own descriptors
(exec echo "replaced"; echo never)
(exec false); echo "status of exec false: $?"
(exec nosuchcommand_xyz) 2>/dev/null; echo "exec of a missing command: $?"
exec 3> f
echo "through fd 3" >&3
exec 3>&-
cat f
