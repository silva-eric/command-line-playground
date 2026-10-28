# File tests -e -f -d -s -h -L -c -b -p -S on things the script creates
t() { label=$1; shift; test "$@"; printf '%s => %s\n' "$label" $?; }
mkdir dir; touch empty; echo data > full
t '-e full' -e full
t '-e missing' -e missing
t '-f full' -f full
t '-f dir' -f dir
t '-d dir' -d dir
t '-d full' -d full
t '-s full' -s full
t '-s empty' -s empty
t '-h full' -h full
t '-L missing' -L missing
t '-c /dev/null' -c /dev/null
t '-b /dev/null' -b /dev/null
t '-p full' -p full
t '-S full' -S full
