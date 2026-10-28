# exit n exits with status n; a plain exit uses the status of the last command
(exit 7); echo "exit 7: $?"
(false; exit); echo "plain exit after false: $?"
(true; exit); echo "plain exit after true: $?"
echo "before the final exit"
exit 3
echo never
