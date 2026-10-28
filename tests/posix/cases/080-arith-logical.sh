# && and || give 1 or 0 and short-circuit: the right side is not evaluated when the left side decides
x=0
echo $((1 && 2)) $((1 && 0)) $((0 || 0)) $((0 || 5))
echo $((0 && (x = 1))) x=$x
echo $((1 || (x = 2))) x=$x
echo $((1 && (x = 3))) x=$x
