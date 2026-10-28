# A whole loop can be piped or redirected
for i in 3 1 2; do echo $i; done | sort
for i in x y; do echo $i; done > out
cat out
