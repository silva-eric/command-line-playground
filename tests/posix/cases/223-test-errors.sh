# Errors in test give status 2 and a message on stderr: a bad integer, a missing operand, a missing ]
t() { label=$1; shift; test "$@"; printf '%s => %s\n' "$label" $?; }
t '1 -eq x' 1 -eq x
t '1 -eq ""' 1 -eq ""
t 'a b' a b
t 'x -gt' x -gt
[ 1 = 1; echo "[ without ] => $?"
