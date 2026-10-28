# Only the results of unquoted expansions are split; literal text in the script is not split by IFS
IFS=:
x=a:b
echo a:b $x "$x"
printf '[%s]' a:b $x; echo
