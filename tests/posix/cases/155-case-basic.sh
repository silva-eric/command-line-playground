# case runs the commands of the first matching pattern; | separates alternatives, * matches anything
for w in apple banana cherry kiwi; do
  case $w in
    apple) echo "$w: first";;
    banana|cherry) echo "$w: second";;
    *) echo "$w: default";;
  esac
done
