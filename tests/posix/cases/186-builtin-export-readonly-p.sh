# export -p and readonly -p list variables in a form the shell can read back
# differs: the format differs: dash prints export X='1' and readonly R='2'; bash prints declare -x X="1" and declare -r R="2" (bash --posix: export X="1", readonly R="2")
export X=1 Y='a b' Q="it's"
export -p | grep -e ' X=' -e ' Y=' -e ' Q='
readonly R=2
readonly -p | grep ' R='
