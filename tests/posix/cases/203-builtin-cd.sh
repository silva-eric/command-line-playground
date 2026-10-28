# cd changes the directory for later commands; a failed cd keeps the old one
# differs: a failed cd returns 2 in dash and 1 in bash
mkdir -p d/e
cd d/e && touch here
cd ../..
[ -f d/e/here ] && echo "the file landed in d/e"
cd nonexist 2>/dev/null; echo "failed cd: $?"
cd d && cd .. && [ -d d ] && echo "back where we started"
cd - >/dev/null; echo "cd - status $?"
[ -d e ] && echo "cd - went back to d"
