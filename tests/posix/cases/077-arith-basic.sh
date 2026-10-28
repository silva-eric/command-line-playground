# Arithmetic expansion: + - * / % on signed integers; / and % truncate toward zero; blanks and newlines are allowed inside
echo $((1 + 2)) $((7 - 10)) $((6 * 7)) $((7 / 2)) $((-7 / 2)) $((7 % 3)) $((-7 % 3)) $((7 % -3))
echo $(( 2+3 )) $((  4 *
  5 ))
