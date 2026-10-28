# Field splitting with the default IFS: runs of spaces, tabs and newlines separate fields; leading and trailing ones produce nothing
v='  a   b	c
d  '
count() { echo $#; }
count $v
printf '[%s]' $v; echo
count "$v"
