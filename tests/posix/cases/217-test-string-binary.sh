# String comparisons = != and (POSIX.1-2024) < >; [ is test with a closing ]
t() { label=$1; shift; test "$@"; printf '%s => %s\n' "$label" $?; }
t 'abc = abc' abc = abc
t 'abc = abd' abc = abd
t 'abc != abd' abc != abd
t '"" = ""' "" = ""
t 'abc < abd' abc \< abd
t 'b > a' b \> a
t '= = =' = = =
t '! = !' ! = !
[ "a b" = "a b" ] && echo "[ ] with a quoted value: true"
