# set -e is also ignored inside a function called where -e is ignored (if condition, left of && or ||)
set -e
f() { false; echo "f continues"; }
if f; then echo "f returned 0"; fi
f || echo never
f && echo "f ok"
echo end
