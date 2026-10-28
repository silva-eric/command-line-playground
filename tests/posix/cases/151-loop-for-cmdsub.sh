# for over the output of a command substitution (split into fields)
for w in $(printf 'a b\nc\n'); do echo "w=$w"; done
n=0; for w in $(echo 1 2 3 4); do n=$((n + w)); done; echo "sum=$n"
