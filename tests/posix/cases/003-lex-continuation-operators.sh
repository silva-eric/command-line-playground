# Line continuation can split an operator; a backslash at the end of a comment does not continue the comment
true &\
& echo "and-and split over two lines"
echo piped |\
cat
x=1; [ $x -eq 1 ] |\
| echo never
echo "status $?"
# a comment ending in a backslash \
echo "this line runs"
