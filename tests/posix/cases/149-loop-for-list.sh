# for over a word list; the words are expanded and split first; the variable keeps its last value afterwards
for w in one two three; do echo "w=$w"; done
list='a b  c'
for w in $list; do echo "split: $w"; done
for w in "$list"; do echo "quoted: $w"; done
for w in; do echo never; done; echo "empty list status $?"
echo "w after the loops: $w"
