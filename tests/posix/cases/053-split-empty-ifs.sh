# With IFS empty no field splitting happens; empty unquoted expansions still vanish; $* and $@ still give one field per parameter
IFS=
count() { echo $#; }
v='a b  c'; count $v
e=; count $e $e
set -- 'x y' z; count $*; count $@
printf '[%s]' $v; echo
