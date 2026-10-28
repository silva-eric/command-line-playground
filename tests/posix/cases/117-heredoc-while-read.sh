# A here-document feeding a while read loop; the loop runs in the current shell, so its variables survive
n=0
while read num word; do
  n=$((n + num)); echo "$word=$num"
done <<EOF
1 one
2 two
3 three
EOF
echo "sum=$n"
