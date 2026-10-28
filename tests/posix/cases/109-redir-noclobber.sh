# set -C (noclobber): > refuses to overwrite an existing file, >| overrides it, >> still appends
# differs: the refused redirection gives status 2 in dash and 1 in bash (messages differ too)
set -C
echo one > f
echo two > f; echo "status $?"
echo three >| f
echo four >> f
cat f
set +C
echo five > f; cat f
