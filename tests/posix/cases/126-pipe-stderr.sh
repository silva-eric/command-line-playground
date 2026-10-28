# Only standard output goes through a pipe, unless 2>&1 is added
{ echo out; echo err >&2; } | cat
{ echo out2; echo err2 >&2; } 2>&1 | cat
cat nofile 2>&1 | grep -c "No such file"
