# A case statement and a loop inside $(...); the (pattern) form with a leading parenthesis works in every shell
x=$(case y in (y) echo matched;; esac)
echo "$x"
y=$(for i in 1 2; do echo "$i"; done)
echo $y
