# <> opens a file for reading and writing on the given descriptor (standard input by default)
echo abc > f
exec 3<> f
read v <&3
echo "read [$v]"
exec 3>&-
cat <> f
