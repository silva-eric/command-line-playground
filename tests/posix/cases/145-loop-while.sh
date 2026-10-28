# while repeats its body while the condition list succeeds
i=0
while [ $i -lt 3 ]; do echo "i=$i"; i=$((i + 1)); done
while false; do echo never; done
echo "status after a loop that never ran: $?"
