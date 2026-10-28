# return inside a file run with '.' ends that file early with the given status
printf 'echo one\nreturn 3\necho never\n' > r.sh
. ./r.sh
echo "status $?"
echo "the script continues"
