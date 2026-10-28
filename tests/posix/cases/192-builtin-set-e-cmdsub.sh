# set -e inside a command substitution
# differs: dash (and bash --posix) keep -e inside $(...), so false ends the substitution and the failed assignment then exits the script with status 1; bash outside POSIX mode turns -e off inside $(...) (unless shopt inherit_errexit, bash 4.4+)
set -e
x=$(false; echo "rest of the substitution")
echo "x=$x"
