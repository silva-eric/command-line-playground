# The status of an if is that of the branch that ran, or 0 when no branch ran
if false; then :; fi; echo "no branch ran: $?"
if true; then (exit 3); fi; echo "then branch: $?"
if false; then :; else (exit 4); fi; echo "else branch: $?"
if (exit 5); then :; else echo "condition status seen in else: $?"; fi
