# Double quotes: $ and ` keep their meaning; a backslash only quotes $ ` " \ and newline, otherwise it stays
x=val
printf '[%s]\n' "$x" "\$x" "a\b" "\"" "\\" "\`" "a\'b" "${x}s" "'$x'" "a   b" "*"
