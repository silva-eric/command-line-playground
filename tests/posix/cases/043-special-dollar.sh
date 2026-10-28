# $$ is a decimal number and is the same inside subshells and command substitutions (the main shell's process ID)
case $$ in ''|*[!0-9]*) echo "not numeric";; *) echo numeric;; esac
a=$$; b=$(echo $$); c=$( (echo $$) )
[ "$a" = "$b" ] && [ "$a" = "$c" ] && echo same
(d=$$; [ "$d" = "$a" ] && echo "same in a subshell")
