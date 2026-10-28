# IFS= read -r keeps a line exactly as it is: leading and trailing blanks and backslashes
IFS= read -r a <<'EOF'
   spaced \ line \\
EOF
printf '[%s]\n' "$a"
