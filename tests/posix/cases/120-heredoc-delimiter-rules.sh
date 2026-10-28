# An empty body; the delimiter must be alone on its line (with other text, or indented in a << here-document, it is part of the body)
cat <<EOF
EOF
echo "empty body done"
cat <<END
END not yet
 END
END
