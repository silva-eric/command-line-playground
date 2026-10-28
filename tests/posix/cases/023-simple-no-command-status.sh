# A command with no command name has status 0, or the status of the last command substitution it performed
false; x=1; echo "plain assignment: $?"
x=$(false); echo "assignment with a failing substitution: $?"
x=$(exit 3) y=$(exit 5); echo "the last substitution counts: $?"
$(exit 4); echo "substitution as the whole command: $?"
false; >f; echo "redirection only: $?"
