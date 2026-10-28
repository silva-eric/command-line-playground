# trap inside $(...) with no arguments may report the parent shell's traps (POSIX allows this special case)
# differs: bash lists the parent's EXIT trap from inside the command substitution; dash prints nothing
trap 'echo bye' EXIT
echo "[$(trap)]"
trap - EXIT
