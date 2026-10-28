# Assignment-only commands set shell variables; values are expanded but not field split or globbed
a=1 b=2 c=$a$b
echo $a $b $c
v="x   y"; w=$v; printf '[%s]\n' "$w"
s=*; printf '[%s]\n' "$s"
e=; printf '[%s]\n' "$e"
n=$((1+2))$(echo z); echo $n
