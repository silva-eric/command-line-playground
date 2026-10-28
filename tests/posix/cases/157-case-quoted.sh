# Quoted characters in case patterns are literal; a pattern from an unquoted variable is still a pattern
p='a*'
for w in abc 'a*' '*'; do
  case $w in
    "$p") echo "[$w] matches \"\$p\" literally";;
    $p) echo "[$w] matches \$p as a pattern";;
    '*') echo "[$w] is a literal star";;
    *) echo "[$w] no match";;
  esac
done
