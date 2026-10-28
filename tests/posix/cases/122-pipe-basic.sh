# A pipeline connects the standard output of each command to the standard input of the next
echo hello | cat
printf 'b\na\nc\n' | sort | head -n 2
printf 'x\ny\n' | cat | cat | grep y
