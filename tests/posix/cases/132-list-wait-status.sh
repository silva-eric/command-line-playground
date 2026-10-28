# wait PID returns that job's exit status; wait without operands returns 0; a PID that is not a child gives 127
(exit 3) & p=$!
wait $p; echo "wait for (exit 3): $?"
false & wait $!; echo "wait for false: $?"
(exit 5) & wait; echo "plain wait: $?"
wait 99999 2>/dev/null; echo "unknown pid: $?"
