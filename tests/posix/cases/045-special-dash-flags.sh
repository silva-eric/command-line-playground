# $- holds the single-letter options in effect; check e, f and u as they are turned on and off
has() { case $- in *$1*) echo "$1 on";; *) echo "$1 off";; esac; }
has e; has f; has u
set -e; has e; set +e; has e
set -f; has f; set +f; has f
set -u; has u; set +u; has u
set -eu; has e; has u; set +eu
