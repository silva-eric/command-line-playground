# read < file opens the file each time (always the first line); a { } group or an exec'd descriptor reads on
printf 'l1\nl2\nl3\n' > f
read a < f; read b < f; echo "$a $b"
{ read a; read b; } < f; echo "$a $b"
exec 3< f; read a <&3; read b <&3; read c <&3; exec 3<&-; echo "$a $b $c"
