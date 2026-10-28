# shift n with n greater than $# is an error and leaves the parameters alone
# differs: dash treats it as a special built-in error and exits the subshell (status 2, message on stderr); bash returns 1 and carries on silently
# note: bash 5 --posix also prints "shift: 5: shift count out of range"; bash 3.2 --posix prints nothing
set -- a b
(shift 5; echo "shift status $?, still $# params: $*")
echo "subshell status $?"
shift 2; echo "now $#"
