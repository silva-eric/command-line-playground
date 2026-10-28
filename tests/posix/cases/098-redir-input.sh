# < reads standard input from a file; the redirection may come first; /dev/null reads as empty
printf 'first\nsecond\n' > in
cat < in
< in cat
read line < in; echo "read: $line"
read line < in; echo "read again (the file is opened again): $line"
x=$(cat < /dev/null); echo "from /dev/null: [$x]"
