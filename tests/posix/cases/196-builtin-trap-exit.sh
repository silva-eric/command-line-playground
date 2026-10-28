# trap 'cmds' EXIT runs when the script ends; a later trap replaces it; trap 0 means EXIT; trap - EXIT removes it
trap 'echo "first exit trap"' EXIT
trap 'echo "second exit trap (replaced the first)"' 0
echo main
trap - EXIT
trap 'echo "third exit trap, set after the removal"' EXIT
