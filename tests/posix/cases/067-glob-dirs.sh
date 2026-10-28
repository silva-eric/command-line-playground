# Patterns with '/' are matched component by component; a trailing '/' matches directories only
mkdir g && cd g || exit 1
mkdir d1 d2 && touch f1 d1/x d2/y d2/z
echo */
echo d*/*
echo */x
echo d?/[yz]
