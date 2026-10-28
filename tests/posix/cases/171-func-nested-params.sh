# Nested calls each get their own positional parameters; shift inside a function does not affect the caller
inner() { echo "inner: $*"; shift; echo "inner after shift: $*"; }
outer() { echo "outer: $*"; inner x y; echo "outer again: $*"; }
set -- top
outer a b
echo "top: $*"
