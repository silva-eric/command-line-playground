# A redirection written after a function body is applied each time the function runs
f() { echo "inside f"; } >> log
f; f
cat log
g() { echo "g writes to stderr"; } >&2
g 2>/dev/null; echo "g silenced: $?"
g 2>&1
