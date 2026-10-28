# The result of an unquoted $((...)) is split with IFS too
IFS=1
echo $((11 + 1)) "$((11 + 1))"
x=$((111)); count() { echo $#; }; count $x
