# Bracket expressions: [abc], [!abc], ranges [a-c] and character classes [[:digit:]] [[:alpha:]]
mkdir g && cd g || exit 1
touch a b c d 1 2 x.txt
echo [abc]
echo [!abc]
echo [a-c]
echo [!a-c]
echo [[:digit:]]
echo [[:alpha:]]
echo [ab][!x]
