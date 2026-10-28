# Arithmetic expansion may contain parameter, command and nested arithmetic expansions
x=4
echo $(( $(echo 3) * 2 )) $(( ${x:-0} + 1 )) $(( $((1 + 1)) * 3 )) $(( x * $(( x + 1 )) ))
