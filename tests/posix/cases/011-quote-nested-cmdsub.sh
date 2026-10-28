# Quotes inside $(...) are independent of the double quotes around the substitution
x="outer $(echo "inner  'q'  $(echo "deep  er")")"
printf '[%s]\n' "$x"
printf '[%s]\n' "$(printf '%s' "a  b")" "$(echo '"')"
