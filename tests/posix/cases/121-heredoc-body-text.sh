# Here-document bodies keep blank lines, leading spaces and '#' characters
cat <<EOF

  indented # not a comment

EOF
echo end
