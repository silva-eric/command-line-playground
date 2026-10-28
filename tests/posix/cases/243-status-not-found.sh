# A command that cannot be found gives status 127 and a message on stderr
nosuchcommand_xyz; echo "status $?"
nosuchcommand_xyz arg 2>/dev/null; echo "silenced: $?"
./missing_file; echo "missing path: $?"
