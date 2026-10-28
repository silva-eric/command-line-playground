# Pathname expansion is applied to the fields left after parameter expansion, command substitution and field splitting
mkdir g && cd g || exit 1
touch a.c b.c a.h
pats='*.c *.h'
echo $pats
echo "$pats"
for p in $pats; do echo "word: $p"; done
echo $(echo '*.h') "$(echo '*.h')"
