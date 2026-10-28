# Traps are reset in subshells: the parent's EXIT trap does not run there, but a subshell can set its own
trap 'echo "parent exit trap"' EXIT
(echo "subshell does not run the parent trap")
(trap 'echo "subshell exit trap"' EXIT; echo "in subshell")
echo "end of script"
