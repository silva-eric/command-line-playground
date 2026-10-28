# With IFS unset, splitting works as with the default space, tab, newline
unset IFS
count() { echo $#; }
v=' a  b	c '
count $v
set -- 'p q' r
echo "$*"
