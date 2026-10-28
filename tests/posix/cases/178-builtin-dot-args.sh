# Extra arguments to '.' are not specified by POSIX
# differs: bash sets the positional parameters to the extra arguments while the file runs and restores them afterwards; dash ignores the extra arguments
printf 'echo "in lib: $# [$*]"\n' > lib.sh
set -- p1 p2
. ./lib.sh one two
. ./lib.sh
echo "after: $# [$*]"
