# The status of a loop is that of the last command its body ran, or 0 if the body never ran
for i in 1 2; do (exit $i); done; echo "for: $?"
while false; do :; done; echo "while: $?"
i=0; while [ $i -lt 1 ]; do i=1; (exit 7); done; echo "while body: $?"
for i in 1; do false; break; done; echo "after break: $?"
