# Grouped options (-ac), an option argument stuck to its option (-bval), and '--' ending the options
set -- -ac -bval -- -x rest
while getopts ab:c opt; do echo "opt=$opt arg=$OPTARG"; done
shift $((OPTIND - 1)); echo "after --: $*"
