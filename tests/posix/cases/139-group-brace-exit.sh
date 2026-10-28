# exit inside { } exits the whole script with that status
echo before
{ echo "in group"; exit 3; }
echo never
