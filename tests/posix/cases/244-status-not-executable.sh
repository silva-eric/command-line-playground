# A file that exists but cannot be executed gives status 126 (a file without x permission, a directory)
printf 'echo hi\n' > script
chmod 644 script
./script; echo "status $?"
mkdir dir
./dir; echo "directory: $?"
