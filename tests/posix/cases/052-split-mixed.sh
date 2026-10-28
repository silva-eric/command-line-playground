# IFS mixing whitespace and ',': whitespace around a ',' belongs to that one delimiter; ',,' still gives an empty field
IFS=' ,'
count() { echo $#; }
v='a, b,,c , d  e'
count $v; printf '[%s]' $v; echo
v=' , x'
count $v; printf '[%s]' $v; echo
v='x , '
count $v; printf '[%s]' $v; echo
