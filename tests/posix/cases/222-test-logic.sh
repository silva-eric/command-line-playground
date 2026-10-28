# ! negates, -a (and) binds tighter than -o (or), and \( \) groups
t() { label=$1; shift; test "$@"; printf '%s => %s\n' "$label" $?; }
t '! ""' ! ""
t '! abc' ! abc
t 'x -a ""' x -a ""
t '"" -o x' "" -o x
t 'x -o "" -a ""' x -o "" -a ""
t '( x -o "" ) -a ""' \( x -o "" \) -a ""
t '! "" -a x' ! "" -a x
t '( x )' \( x \)
t '! ( x = y )' ! \( x = y \)
