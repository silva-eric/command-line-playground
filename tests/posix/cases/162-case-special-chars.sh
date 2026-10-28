# Patterns can match special characters when they are quoted or escaped
for w in 'a|b' '(x)' 'semi;' 'sp ace'; do
  case $w in
    'a|b') echo "pipe";;
    \(*\)) echo "parens";;
    *\;) echo "semicolon";;
    *' '*) echo "space";;
  esac
done
