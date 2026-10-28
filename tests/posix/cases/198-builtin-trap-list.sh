# trap with no arguments lists the traps in a form that can be reused as input
# differs: bash outside POSIX mode writes signal names with the SIG prefix (SIGINT); dash and bash --posix write INT
trap 'echo bye' EXIT
trap 'echo int' INT
trap
trap - EXIT INT
trap
echo "after reset"
