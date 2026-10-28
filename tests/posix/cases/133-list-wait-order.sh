# Waiting for two background jobs one by one, in a different order from the one they were started in
(sleep 0.1; exit 2) & a=$!
(exit 5) & b=$!
wait $b; echo "b: $?"
wait $a; echo "a: $?"
