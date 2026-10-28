# A function can override a utility of the same name; 'command' bypasses functions; unset -f removes the function
cat() { echo "my cat: $*"; }
cat file
echo "real cat" | command cat
unset -f cat
echo "after unset -f" | cat
