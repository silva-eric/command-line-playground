# Inside backquotes \$ \` \\ lose their backslash before the inner command is parsed; $(...) keeps its text as written
a=`echo \$HOME`
b=$(echo \$HOME)
c=`printf '%s\n' '\\'`
d=$(printf '%s\n' '\\')
printf '%s\n' "$a" "$b" "$c" "$d"
