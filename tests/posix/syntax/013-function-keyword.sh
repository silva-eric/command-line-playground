# The bash 'function name { ... }' form is not POSIX syntax
# differs: dash reports a syntax error at '}' (it reads 'function' as a command name); bash defines and runs the function
function f { echo "in f"; }
f
echo after
