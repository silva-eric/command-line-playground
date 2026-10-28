# Quoting any part of the delimiter (<<'EOF', <<"EOF", <<\EOF, <<E"O"F) turns off all expansion in the body
x=val
cat <<'EOF'
single: $x $(echo no) \$x \\
EOF
cat <<"EOF"
double: $x
EOF
cat <<\EOF
backslash: $x
EOF
cat <<E"O"F
partial: $x
EOF
