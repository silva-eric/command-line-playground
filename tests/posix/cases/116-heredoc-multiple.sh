# Several here-documents on one line are read in order, also two for one command (stdin and fd 3)
cat <<A; cat <<B
first
A
second
B
f() { cat; cat <&3; }
f <<ONE 3<<TWO
on stdin
ONE
on fd 3
TWO
