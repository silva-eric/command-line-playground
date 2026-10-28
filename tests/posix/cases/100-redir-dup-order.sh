# Redirections are processed left to right: '>f 2>&1' sends both streams to f; '2>&1 >f' sends stderr to the old stdout
both() { echo out; echo err >&2; }
both > f1 2>&1
echo "f1:"; cat f1
both 2>&1 > f2
echo "f2:"; cat f2
