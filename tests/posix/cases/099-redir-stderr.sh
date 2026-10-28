# 2> sends standard error to a file, 2>/dev/null discards it, 2>> appends
cat nofile 2>/dev/null; echo "status $?"
cat nofile 2> err; cat err
cat nofile 2>> err; grep -c nofile err
