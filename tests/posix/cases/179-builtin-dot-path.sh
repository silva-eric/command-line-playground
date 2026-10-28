# '.' with a name that has no '/' searches PATH, not the current directory; not finding the file is an error that exits a POSIX shell
# differs: bash outside POSIX mode also looks in the current directory and finds lib.sh; dash prints '.: lib.sh: not found' and exits the subshell with status 2
# note: bash 3.2 --posix also finds lib.sh in the current directory; bash 5 --posix does not ('file not found') and exits the subshell with status 1
printf 'echo "lib.sh was found"\n' > lib.sh
(. lib.sh; echo "continued: $?")
echo "status $?"
