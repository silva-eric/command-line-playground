# Variables in arithmetic: with or without '$'; an unset or empty variable counts as 0
x=5; unset u; e=
echo $((x + 1)) $(($x + 1)) $((u + 1)) $((e + 1)) $(($e + 1)) ${u:-$((x * x))}
n=-3; echo $((n * 2)) $((-n)) $((n - -n))
