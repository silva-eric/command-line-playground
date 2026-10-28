# set -x writes each command to stderr after expansion, prefixed with '+ ' (PS4), until set +x
x=val
set -x
echo $x two
: ${x}
set +x
echo done
