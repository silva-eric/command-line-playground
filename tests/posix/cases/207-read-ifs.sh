# read with IFS given as a prefix assignment (the shell's own IFS is unchanged); non-blank IFS characters do not trim spaces
IFS=: read user pw uid rest <<EOF
root:x:0:0:root:/root
EOF
echo "[$user] [$pw] [$uid] [$rest]"
IFS=, read a b <<EOF
x , y,z
EOF
echo "[$a] [$b]"
v='p q'; set -- $v; echo "IFS unchanged: $# fields"
