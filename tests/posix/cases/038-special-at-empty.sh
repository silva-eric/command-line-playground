# With no positional parameters "$@" expands to no field at all, while "$*" gives one empty field; text around "$@" sticks to the first and last parameters
count() { echo $#; }
set --
count "$@"
count "$*"
count "x$@"
count ${1+"$@"}
set -- a b
count "x$@y"
printf '[%s]' "x$@y"; echo
