# Without -r, read removes a backslash and keeps the next character, and backslash-newline continues the line; with -r backslashes stay
read a <<'EOF'
a\tb\\c \
continued
EOF
printf '[%s]\n' "$a"
read -r a <<'EOF'
a\tb\\c \
EOF
printf '[%s]\n' "$a"
