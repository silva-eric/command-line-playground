# until repeats its body until the condition list succeeds
i=0
until [ $i -ge 3 ]; do echo "i=$i"; i=$((i + 1)); done
until true; do echo never; done; echo "status $?"
