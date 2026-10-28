# Assignment operators = += -= *= /= %= <<= >>= &= ^= |= change the variable and give its new value
x=5
echo $((x = 6)) $((x += 2)) $((x -= 1)) $((x *= 3)) $((x /= 4)) $((x %= 3)) $x
echo $((x <<= 3)) $((x >>= 1)) $((x &= 7)) $((x |= 8)) $((x ^= 5)) $x
: $((y = 10)); echo "y=$y"
