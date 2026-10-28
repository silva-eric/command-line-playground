# A failed redirection on a regular command: the command does not run, the status is non-zero, the script goes on
# differs: dash gives status 2 for a failed redirection, bash gives 1 (messages differ too)
cat < nonexist; echo "input redirection: $?"
echo x > nodir/f; echo "output redirection: $?"
echo x >&5; echo "bad descriptor: $?"
echo end
