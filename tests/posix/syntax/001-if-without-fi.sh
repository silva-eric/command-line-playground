# An if without fi: the commands before it run, then the parser hits the end of the file (status 2)
echo "this line runs first"
if true; then
  echo "inside, never runs"
