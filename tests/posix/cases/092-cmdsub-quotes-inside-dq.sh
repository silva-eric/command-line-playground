# Inside double quotes, $(...) may contain double quotes and ')' in quotes freely; backquotes need \" for inner double quotes
f="`echo \"dq in backquotes\"`"
g="$(echo "dq in dollar-paren")"
h="$(echo 'paren ) in single quotes')"
i="$(echo "paren ) in double quotes")"
printf '%s\n' "$f" "$g" "$h" "$i"
