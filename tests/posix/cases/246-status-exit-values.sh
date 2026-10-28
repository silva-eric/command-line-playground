# Exit statuses 0 to 255 pass through unchanged; the status of a script is that of its last command
for n in 0 1 2 42 255; do (exit $n); printf '%s ' $?; done; echo
sh -c 'exit 7'; echo "sh -c 'exit 7': $?"
false
