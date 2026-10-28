# $# is the number of positional parameters; it changes with set and shift and is the function's own inside a function
echo $#
set -- a b c; echo $#
shift; echo $#
f() { echo "in f: $#"; }
f x y z w
echo "after f: $#"
set --; echo $#
