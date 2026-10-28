# The status of an assignment or of a command without a name is that of its last command substitution
x=$(false); echo "x=\$(false): $?"
x=$(exit 5); echo "x=\$(exit 5): $?"
echo "$(false)"; echo "echo \$(false): $?"
$(exit 4); echo "bare \$(exit 4): $?"
x=$(true) y=$(exit 2); echo "two substitutions: $?"
