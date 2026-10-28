# Option parsing stops at the first operand or after '--'; at the end the variable is set to '?'
set -- -a file -b
while getopts ab opt; do echo "opt=$opt"; done
echo "stopped at OPTIND=$OPTIND, opt=$opt"
OPTIND=1
set -- -a -- -b
while getopts ab opt; do echo "opt=$opt"; done
echo "OPTIND=$OPTIND, next argument: $3"
