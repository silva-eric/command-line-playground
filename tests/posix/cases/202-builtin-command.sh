# command runs a name without looking up functions; command -v shows how a name would be found
# differs: command -v of an unknown name returns 127 in dash and 1 in bash
f() { echo "function f"; }
command -v f
command -v echo
command -v if
command -v nosuchcmd_xyz; echo "status $?"
echo() { printf 'function echo\n'; }
echo hi
command echo "the built-in echo"
unset -f echo
