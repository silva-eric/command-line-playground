# ${x?word} and ${x:?word} write word (or a default message) to stderr and exit a non-interactive shell; subshells keep the script going
# differs: the subshell exits with status 2 in dash and 1 in bash; the default messages differ too ("parameter not set" vs "parameter null or not set")
unset u; e=
(echo "${u?custom message}"; echo not reached)
echo "status $?"
(echo "[${e?msg}]")
echo "status $?"
(echo "${e:?empty is not ok}"; echo not reached)
echo "status $?"
(: "${u?}")
echo "status $?"
s=ok; echo "${s:?never shown}"
