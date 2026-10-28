# eval joins its arguments with spaces and runs the result as shell code in the current shell
eval 'x=1; y=2'; echo "x=$x y=$y"
cmd='echo a; echo b'; eval "$cmd"
a=b; b=deep; eval "echo \$$a"
eval echo '$x' "'quoted  text'"
eval; echo "empty eval: $?"
eval false; echo "eval false: $?"
eval 'f() { echo "defined by eval"; }'; f
