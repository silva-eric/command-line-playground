# The redirection target is expanded (parameters, command substitution) but not field split
# differs: bash outside POSIX mode splits the word and fails with "ambiguous redirect" (status 1); dash and bash --posix create a file named 'a b'
f=out; echo hi > "$f"; cat $f
echo sub > $(echo out2); cat out2
n='a b'
echo spaced > $n
echo "status $?"
cat 'a b' 2>/dev/null || echo "no file named 'a b'"
