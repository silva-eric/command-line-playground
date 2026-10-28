# ${x+word} gives word when x is set; ${x:+word} only when x is set and not empty
unset u; e=; s=val
echo "[${u+w}] [${e+w}] [${s+w}]"
echo "[${u:+w}] [${e:+w}] [${s:+w}]"
echo "[${s:+$s and more}]"
set -- one; echo "[${1+set}] [${2+set}]"
