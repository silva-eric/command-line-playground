# set -u: expanding an unset variable is an error that exits the shell; ${x-default}, empty variables and $@ / $* are fine
# differs: the subshell exits with status 2 in dash and 1 in bash (messages: "parameter not set" vs "unbound variable")
set -u
echo "default: ${u-none}"
echo "params: $# [$*] [$@]"
e=; echo "empty is fine: [$e]"
(echo "$u"; echo never)
echo "subshell status $?"
set +u
echo "unset is fine again: [$u]"
