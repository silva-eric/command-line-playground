# case patterns use pattern-matching notation: ? * [...] [!...] and character classes
for w in a ab abc 7 - x.y; do
  case $w in
    [0-9]) r=digit;;
    [!a-z]) r="not a lowercase letter";;
    ?) r="one character";;
    a?) r="a and one more";;
    *.*) r="has a dot";;
    [[:alpha:]]*) r="starts with a letter";;
  esac
  echo "$w: $r"
done
