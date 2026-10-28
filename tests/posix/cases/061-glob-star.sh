# '*' matches any string but not a leading '.', and the matches are sorted; '.*' matches dot files
# note: bash 5.2 (Ubuntu 24.04) has globskipdots on by default, so there '.*' gives only '.hidden'; dash and bash 3.2 also list '.' and '..'
mkdir g && cd g || exit 1
touch b a c .hidden ab
echo *
echo a*
echo *b
echo .*
