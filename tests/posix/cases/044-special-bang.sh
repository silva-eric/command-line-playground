# $! is empty until an asynchronous command starts, then it holds that job's decimal process ID
echo "before: [$!]"
true &
p=$!
case $p in ''|*[!0-9]*) echo "not numeric";; *) echo numeric;; esac
wait "$p"; echo "wait status $?"
true; [ "$p" = "$!" ] && echo "unchanged by foreground commands"
