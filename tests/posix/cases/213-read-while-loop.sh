# A while read -r loop over a here-document, numbering the lines
n=0
while read -r line; do
  n=$((n + 1))
  echo "$n: $line"
done <<'EOF'
first line
  second, indented
third \ with a backslash
EOF
echo "total $n"
