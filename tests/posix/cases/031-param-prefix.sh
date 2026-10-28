# ${x#pattern} removes the shortest matching prefix, ${x##pattern} the longest
p=/usr/local/bin/tool
echo ${p#*/} ${p##*/}
f=archive.tar.gz
echo ${f#*.} ${f##*.}
echo ${f#a} ${f#[abc]} ${f##[a-z]*r} ${f#?} ${f#nomatch}
echo ${f#"$f"}end ${f##*}end
