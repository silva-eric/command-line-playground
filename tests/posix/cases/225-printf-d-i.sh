# printf %d and %i: width, '-' and '0' flags, precision, signs, and octal, hex and 'c character arguments
printf '[%d][%i][%5d][%-5d][%05d][%.3d]\n' 42 -7 42 42 42 7
printf '[%+d][% d][%d]\n' 5 5 -0
printf '%d %d %d %d\n' 0x10 010 "'A" "'a"
printf '%d %d\n' +4 007
