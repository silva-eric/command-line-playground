# A pattern may start with '('; bodies can be empty or span several lines
v=b
case $v in
  (a|b) echo "matched (a|b)"
        echo "second line";;
  (c) ;;
esac
r=$(case $v in (b) echo inside-substitution;; esac)
echo "$r"
