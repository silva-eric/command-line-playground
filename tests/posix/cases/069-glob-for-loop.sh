# Pathname expansion in a for word list; with no match the pattern itself is used
mkdir g && cd g || exit 1
touch one.txt two.txt three.log
for f in *.txt; do echo "txt: $f"; done
for f in *.md; do echo "md: $f"; done
