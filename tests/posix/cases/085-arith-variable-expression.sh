# A variable holding an expression (y=2+3): $y is pasted in as text first (2+3*2); a bare y must hold an integer
# differs: bash evaluates the value of a bare y as an expression (2+3, so 10); dash requires an integer and fails with "Illegal number" (status 2)
y=2+3
echo $(($y * 2))
(echo $((y * 2)))
echo "status $?"
