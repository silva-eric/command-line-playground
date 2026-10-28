# set -- replaces the positional parameters (also from a split expansion); set -- alone clears them; -- protects values starting with '-'
set -- a b c; echo "$# [$*]"
set -- -x -e; echo "$# [$*]"
case $- in *x*|*e*) echo "options changed";; *) echo "options unchanged";; esac
set --; echo "$# [$*]"
set one two; echo "$# [$*]"
line='alpha beta  gamma'; set -- $line; echo "$#: $2"
