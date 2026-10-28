# A command can continue on the next line after |, && and ||
echo a |
cat
true &&
echo "and on the next line"
false ||
echo "or on the next line"
