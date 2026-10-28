# ':' does nothing and succeeds, but its arguments are still expanded, so their side effects happen
false; :; echo "status $?"
: ${x=assigned}; echo "x=$x"
: $((n = 5)); echo "n=$n"
: > created; [ -f created ] && echo "file created by ': >'"
: "$(echo "side effect on stderr" >&2)"
