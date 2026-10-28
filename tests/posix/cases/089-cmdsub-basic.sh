# $(...) and backquotes substitute a command's output; all trailing newlines are removed, inner ones are kept
x=$(printf 'a\n\n\n'); printf '[%s]\n' "$x"
y=$(printf 'a\n\nb\n'); printf '[%s]\n' "$y"
z=`echo back`; echo "$z"
echo "$(echo one) `echo two`"
w=$(printf '\n\n'); printf '[%s]\n' "$w"
