# break leaves the loop, continue goes on with the next iteration
for i in 1 2 3 4 5; do
  [ $i -eq 2 ] && continue
  [ $i -eq 4 ] && break
  echo "i=$i"
done
i=0
while true; do i=$((i + 1)); [ $i -gt 3 ] && break; echo "w=$i"; done
