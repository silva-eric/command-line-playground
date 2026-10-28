# >&2 and 1>&2 write to standard error; 2>&1 merges standard error into standard output
echo "to stderr" >&2
echo "also stderr" 1>&2
{ echo "merged into stdout" >&2; } 2>&1
