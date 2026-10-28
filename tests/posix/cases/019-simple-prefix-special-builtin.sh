# Prefix assignments before a special built-in (':' and eval here) stay set after it (POSIX)
# differs: bash outside POSIX mode makes them temporary (X stays 'before', Y goes back to 1); bash --posix keeps them like dash
X=before
X=after :
echo "after colon: X=$X"
Y=1
Y=2 eval 'echo "inside eval: Y=$Y"'
echo "after eval: Y=$Y"
