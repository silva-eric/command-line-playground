# '?' matches exactly one character, but not a leading '.'
mkdir g && cd g || exit 1
touch a ab abc .x
echo ?
echo ??
echo ???
echo a?
echo ?b?
