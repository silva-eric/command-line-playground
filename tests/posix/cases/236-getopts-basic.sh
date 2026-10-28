# getopts parses options one at a time: OPTARG holds an option's argument, OPTIND the index of the next argument
# differs: dash sets OPTARG to an empty string for an option without an argument; bash unsets it (POSIX says it shall be unset)
set -- -a -b value -c file1 file2
while getopts ab:c opt; do
  echo "opt=$opt OPTARG=[${OPTARG-unset}] OPTIND=$OPTIND"
done
shift $((OPTIND - 1))
echo "operands: $*"
