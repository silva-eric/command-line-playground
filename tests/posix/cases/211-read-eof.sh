# read returns 1 at end of file; a last line without a newline is still stored but the status is 1; an empty line gives status 0
printf 'last' > f
read x < f; echo "$? [$x]"
read x < /dev/null; echo "$? [$x]"
printf '\nnext\n' > g
{ read a; echo "empty line: $? [$a]"; read b; echo "next line: $? [$b]"; read c; echo "at the end: $? [$c]"; } < g
