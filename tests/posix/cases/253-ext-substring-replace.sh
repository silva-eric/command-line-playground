# ${x:offset:length} and ${x/pattern/string} are bash extensions; dash reports "Bad substitution" (run in subshells)
# differs: dash fails with "Bad substitution" (status 2); bash expands them
x=hello
(echo "${x:1:3}")
echo "status $?"
(echo "${x/l/L}")
echo "status $?"
