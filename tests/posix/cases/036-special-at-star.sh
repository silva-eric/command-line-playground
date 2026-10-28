# Unquoted $@ and $* are split into fields (empty ones vanish); "$@" keeps every parameter as it is; "$*" joins them into one field
set -- 'a b' c '' d
count() { echo $#; }
count $@
count $*
count "$@"
count "$*"
printf '[%s]' "$@"; echo
printf '[%s]' "$*"; echo
printf '[%s]' ${@} "${*}"; echo
