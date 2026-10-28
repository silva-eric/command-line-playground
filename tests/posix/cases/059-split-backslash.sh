# Backslashes and quotes that come out of an expansion are ordinary characters: they do not quote anything
v='a\ b "c d"'
count() { echo $#; }
count $v
printf '[%s]' $v; echo
