# exit inside a function exits the whole script
f() { echo "in f"; exit 5; echo never; }
f
echo never
