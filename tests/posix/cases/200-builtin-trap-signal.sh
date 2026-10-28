# A trap on a signal runs when the shell receives that signal (sent to itself with kill)
trap 'echo "got TERM"' TERM
kill -TERM $$
echo "after kill"
trap 'echo "got USR1"' USR1
kill -s USR1 $$
echo end
