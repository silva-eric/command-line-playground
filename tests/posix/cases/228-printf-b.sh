# printf %b expands backslash escapes in its argument: \n \t \\ \0NNN (octal) and \c (stop all output)
printf '[%b]\n' 'a\nb' 'tab\there' 'back\\slash' 'octal \0101\0102'
printf '%b' 'stops here\c' 'never printed'
echo
