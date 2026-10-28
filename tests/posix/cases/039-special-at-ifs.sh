# Unquoted $* and $@ with a non-whitespace IFS, an empty IFS and IFS unset
count() { echo $#; }
set -- 'a:b' 'c d'
IFS=:; count $*; count $@; count "$*"
IFS=; count $*; count $@
unset IFS; count $* $@
