# read splits a line with IFS: one word per variable, the last variable gets the rest of the line, missing words leave variables empty
read a b c <<EOF
one two three four
EOF
echo "[$a] [$b] [$c]"
read a b c <<EOF
only
EOF
echo "[$a] [$b] [$c]"
read a <<EOF
   leading and trailing blanks are removed
EOF
echo "[$a]"
