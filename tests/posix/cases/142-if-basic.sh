# if / elif / else / fi run the first branch whose condition list succeeds; the condition is a list (its last status counts)
for n in 1 2 3; do
  if [ $n -eq 1 ]; then echo "one"
  elif [ $n -eq 2 ]; then echo "two"
  else echo "other"
  fi
done
if false; true; then echo "only the last command of the condition counts"; fi
