# return outside any function (at the top level of the script) is unspecified by POSIX; run in a subshell
# differs: dash treats it like exit (the subshell ends with status 3); bash prints an error, sets status 1 and carries on
# note: bash 5 gives status 2 instead of 1, and bash 5 --posix exits the subshell with status 2
(return 3; echo "after a top-level return: $?")
echo "subshell status: $?"
