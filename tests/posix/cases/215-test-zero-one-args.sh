# test with no argument is false; with one argument it is true if the argument is not empty, even for '-n', '-z' or '!'
t() { label=$1; shift; test "$@"; printf '%s => %s\n' "$label" $?; }
t 'test'
t 'test abc' abc
t 'test ""' ""
t 'test -n' -n
t 'test -z' -z
t 'test !' !
