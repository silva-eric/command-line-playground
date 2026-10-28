# Silent mode (optstring starting with ':'): no messages; an unknown option gives '?' with OPTARG set to it, a missing argument gives ':'
set -- -x -b
while getopts :ab: opt; do echo "opt=$opt OPTARG=$OPTARG"; done
