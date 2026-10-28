# A here-document whose delimiter line never comes: the body runs to the end of the file
# note: bash 4.0+ (Ubuntu ships 5.2) also prints a warning about the missing delimiter on stderr; dash and bash 3.2 say nothing
cat <<EOF
body line
