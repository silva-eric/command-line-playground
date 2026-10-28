# OPTIND=1 restarts parsing (here inside a function); getopts can also parse an explicit list instead of "$@"
parse() { OPTIND=1; while getopts xy: o; do printf '%s%s ' "$o" "$OPTARG"; done; echo "(OPTIND=$OPTIND)"; }
parse -x -y 1
parse -y 2 -x
OPTIND=1
while getopts pq: o -p -q val; do echo "explicit: $o $OPTARG"; done
