# An executable file without a #! line is run by a shell when it is executed
printf 'echo "child script ran with $# arguments"\nexit 6\n' > script
chmod 755 script
./script a b; echo "status $?"
