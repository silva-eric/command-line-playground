# The conditional operator ?: , also nested
a=5
echo $((a > 3 ? 1 : 0)) $((a < 3 ? 10 : 20)) $((a > 3 ? a > 4 ? 2 : 1 : 0)) $((0 ? 1 : 0 ? 2 : 3))
