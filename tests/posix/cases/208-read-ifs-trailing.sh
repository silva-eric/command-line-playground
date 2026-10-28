# read with trailing IFS delimiters: when only one field is left, the last variable gets it without its delimiter; otherwise it gets the rest of the line as it is (only trailing IFS white space is removed)
IFS=: read a b <<EOF
x:y:z:
EOF
echo "[$a] [$b]"
IFS=: read a b <<EOF
x:y:
EOF
echo "[$a] [$b]"
IFS=' :' read a b <<EOF
  x : y : z
EOF
echo "[$a] [$b]"
