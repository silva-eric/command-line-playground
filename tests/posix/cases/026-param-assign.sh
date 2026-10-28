# ${x=word} and ${x:=word} assign word to x (the colon form also when x is empty)
unset u; e=
echo "[${u=one}] u=$u"
echo "[${e=two}] e=[$e]"
echo "[${e:=three}] e=$e"
unset u
: ${u:=four}
echo "u=$u"
: ${u:=five}
echo "u=$u"
