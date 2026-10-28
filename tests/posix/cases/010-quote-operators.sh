# Quoted operator and reserved characters are plain text
printf '%s ' '|' "&" \; '<' ">" '(' \) '{' '}' '!' '#' '*' '?' '[' ']' '~' '=' '$'
echo
printf '%s\n' "a|b;c&d" 'x>y<z' "(sub)"
