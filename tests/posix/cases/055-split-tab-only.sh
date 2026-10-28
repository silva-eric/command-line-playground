# IFS set to a tab only: spaces are ordinary characters
IFS='	'
v='a b	c d'
count() { echo $#; }
count $v
printf '[%s]' $v; echo
