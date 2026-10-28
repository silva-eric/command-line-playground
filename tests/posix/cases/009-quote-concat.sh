# Adjacent quoted and unquoted parts join into one word; empty quotes give an empty argument, an unquoted empty expansion gives none
x=X
printf '[%s]\n' a'b'"c"d "$x"'$x'$x ''"" a""b '' ""
count() { echo $#; }
e=
count '' "" $e "$e" ''$e "$e$e"
count $e $e
