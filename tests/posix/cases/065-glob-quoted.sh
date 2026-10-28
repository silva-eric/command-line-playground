# Quoted pattern characters are literal; a pattern character coming from an unquoted variable still globs
mkdir g && cd g || exit 1
touch a b
echo "*" '*' \* "a"*
x='*'
echo $x "$x"
y='[ab]'
echo $y "$y"
