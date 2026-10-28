# Integer constants: decimal, octal (leading 0) and hexadecimal (0x or 0X), also as variable values
echo $((010)) $((0x1F)) $((0X10)) $((0)) $((007 + 1)) $((0x10 * 010))
x=011; echo $((x)) $(($x))
