# The command name can come from an expansion; it is field split like any other word, and an empty unquoted expansion disappears
cmd=echo; $cmd hello
"$cmd" quoted
set -- printf '%s|' a b; "$@"; echo
c='echo split  words'; $c
e=; $e echo "empty expansion vanished before the command name"
