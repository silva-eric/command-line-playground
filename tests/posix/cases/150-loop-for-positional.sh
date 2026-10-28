# for without 'in' loops over the positional parameters, as "$@" would
set -- 'a b' c
for x; do echo "[$x]"; done
for x do echo "no semicolon [$x]"; done
f() { for arg; do echo "f arg [$arg]"; done; }
f p 'q r'
