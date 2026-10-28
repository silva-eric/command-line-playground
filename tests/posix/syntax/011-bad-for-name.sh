# A for loop whose variable is not a valid name
# differs: outside POSIX mode bash reports "not a valid identifier" as a run-time error and carries on (prints 'after', status 0); dash and bash --posix stop with status 2
echo before
for 1x in a b; do echo "$1x"; done
echo after
