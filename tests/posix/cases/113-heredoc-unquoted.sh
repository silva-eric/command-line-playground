# Unquoted here-document: parameter, command and arithmetic expansion happen; \$ \` \\ are escapes; quotes are ordinary characters
x=val
cat <<EOF
x is $x, cmd $(echo sub), arith $((2 * 3)), braces ${x}s
escaped \$x and \`echo no\` and a backslash \\ stays one
quotes stay: 'single' "double" \"backslash-dq\"
EOF
