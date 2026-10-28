# $name and ${name}: braces delimit the name; an unset variable expands to nothing; $10 is ${1} followed by 0
x=val
echo $x ${x} ${x}s "$x"s [$xs]
echo "${x}_$x-$x.$x"
set -- a b c d e f g h i j k
echo $1 ${1} $10 ${10} ${11}
