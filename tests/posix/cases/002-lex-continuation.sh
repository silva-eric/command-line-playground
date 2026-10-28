# Backslash-newline is a line continuation: it is removed before words are formed, even mid-word and inside double quotes, but not inside single quotes
echo one \
two \
three
ec\
ho joined
echo "dq\
uoted"
printf '%s\n' 'single\
quoted'
x=con\
cat; echo $x
