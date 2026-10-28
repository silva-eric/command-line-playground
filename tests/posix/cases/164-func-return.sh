# return n sets the function's status; a plain return, or the end of the body, uses the status of the last command
f() { return 3; echo never; }
f; echo "return 3: $?"
g() { false; return; }
g; echo "plain return after false: $?"
h() { true; false; }
h; echo "end of body: $?"
