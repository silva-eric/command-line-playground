# A readonly variable cannot be assigned or unset; trying is an error that exits a non-interactive POSIX shell (subshells here)
# differs: dash exits the subshell (status 2); bash outside POSIX mode prints an error, returns 1 and carries on
# note: bash --posix exits the subshell on the assignment (status 1) but carries on after the failed unset
readonly r=1
(r=2; echo "after the assignment: $?")
echo "status $?"
(unset r; echo "after unset: $?")
echo "status $?"
echo "r=$r"
