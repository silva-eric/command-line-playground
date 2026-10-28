# ${1=word} and ${1:=word} cannot assign to a positional parameter: an expansion error that exits the (sub)shell
# differs: the subshell exits with status 2 in dash and 1 in bash (messages: "1: bad variable name" vs "$1: cannot assign in this way")
(: ${1=x}; echo "not reached")
echo "status $?"
(: ${1:=x}; echo "not reached")
echo "status $?"
