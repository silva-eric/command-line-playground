# Command substitutions nest: $( $( ) ) directly, backquotes with \` inside, and a subshell inside $( ( ) )
a=$(echo $(echo $(echo deep)))
b=`echo \`echo inner\``
c=$(echo "$(echo "two levels")")
d=$( (echo subshell inside) )
printf '%s\n' "$a" "$b" "$c" "$d"
