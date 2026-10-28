# Bracket edge cases: ']' first in the list is literal, '-' first is literal, an unclosed '[' is an ordinary character
mkdir g && cd g || exit 1
touch ']' '-' b
echo []]
echo [!]-]
echo [-x]
echo [x
