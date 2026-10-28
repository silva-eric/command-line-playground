# Prefix assignments before a regular built-in (true, printf, read) are temporary; the arguments were expanded before the assignment
unset W
W=w1 true; echo "after true: [${W-unset}]"
W=w2 printf '%s\n' "printf argument: [${W-unset}]"
echo "after printf: [${W-unset}]"
IFS=: read a b <<EOF
one:two
EOF
v='p q'; set -- $v
echo "read got [$a] [$b]; IFS is default again: $# fields"
