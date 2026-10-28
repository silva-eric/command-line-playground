# An option missing its argument sets the variable to '?', and getopts writes a message to stderr
set -- -a -b
while getopts ab: opt; do echo "opt=$opt"; done
echo "OPTIND=$OPTIND"
