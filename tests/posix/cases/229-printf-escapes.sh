# Escapes in the format itself: \n \t \\ \NNN (one to three octal digits); %% prints a percent sign
printf 'a\tb\\c\n'
printf '\101\102\103 \60\61\n'
printf '100%%\n'
printf '%s%%\n' 50
