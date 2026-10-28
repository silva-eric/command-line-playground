# test -n (not empty) and -z (empty), with quoted variables
t() { label=$1; shift; test "$@"; printf '%s => %s\n' "$label" $?; }
e=; s=word
t '-n abc' -n abc
t '-n ""' -n ""
t '-z ""' -z ""
t '-z abc' -z abc
t '-n "$e"' -n "$e"
t '-z "$s"' -z "$s"
