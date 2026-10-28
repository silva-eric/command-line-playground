# In an unquoted here-document backslash-newline joins lines; in a quoted one it is kept
cat <<EOF
joined \
line
EOF
cat <<'EOF'
kept \
line
EOF
