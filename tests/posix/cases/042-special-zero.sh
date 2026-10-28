# $0 is the script name as given to the shell; it does not change inside functions; sh -c takes it from the next argument
echo "$0"
f() { echo "in f: $0"; }
f
sh -c 'echo "sh -c: $0 $1"' name arg
