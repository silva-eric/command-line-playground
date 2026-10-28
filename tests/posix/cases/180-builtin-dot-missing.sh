# '.' with a file that does not exist is an error that exits a non-interactive POSIX shell (a subshell here)
# differs: bash outside POSIX mode returns 1 and carries on ('continued: 1'); dash (status 2) and bash --posix (status 1) exit the subshell
(. ./nope; echo "continued: $?")
echo "status $?"
