# Numbered descriptors: exec n<file and n>file open them in the shell; <&n and >&n duplicate them; n<&- and n>&- close them
printf 'line1\nline2\n' > in
exec 3< in
read a <&3
read b <&3
exec 3<&-
echo "$a / $b"
exec 4> out
echo "to fd 4" >&4
echo "again" 1>&4
exec 4>&-
cat out
