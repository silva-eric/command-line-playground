# printf %s with field width, '-' (left-justify) and precision; arguments are not interpreted; no newline unless asked
printf '[%s]\n' hello
printf '[%5s][%-5s][%.2s][%5.1s]\n' abc abc abc abc
printf '[%s]\n' 'a\nb' '%d'
printf 'one'; printf 'two'; printf '\n'
printf '%s' a b c; printf '\n'
