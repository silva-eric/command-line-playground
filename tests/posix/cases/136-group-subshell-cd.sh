# cd inside ( ) does not change the directory of the shell
mkdir d
(cd d && touch inside)
[ -f d/inside ] && echo "file created inside d"
[ -f inside ] || echo "still in the original directory"
