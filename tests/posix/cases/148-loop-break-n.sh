# break n and continue n act on the n-th enclosing loop; a too large n means the outermost loop
for i in 1 2 3; do
  for j in a b c; do
    [ $j = b ] && continue 2
    [ $i = 3 ] && break 2
    echo "$i$j"
  done
done
echo "end i=$i j=$j"
for i in 1 2; do for j in a b; do break 9; done; echo never; done
echo "break 9 left both loops: $i$j"
