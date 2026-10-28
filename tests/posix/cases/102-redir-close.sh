# >&- closes standard output and 2>&- closes standard error; a utility writing to a closed descriptor fails
# note: an external utility (cat) is used on purpose: bash 3.2 has a bug where a built-in echo writing to a closed stdout still shows its text once the descriptor is restored
echo abc > f
(cat f >&-) 2>/dev/null; echo "cat with closed stdout: $?"
cat nofile 2>&-; echo "cat with closed stderr: $?"
(exec >&-; cat f 2>/dev/null; echo "closed by exec: $?" >&2) 2>&1
