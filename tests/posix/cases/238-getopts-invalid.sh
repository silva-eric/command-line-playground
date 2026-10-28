# An unknown option sets the variable to '?', and getopts writes a message to stderr; parsing goes on
set -- -x -a
while getopts a opt; do echo "opt=$opt"; done
echo "OPTIND=$OPTIND"
