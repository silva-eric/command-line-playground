# ${x%pattern} removes the shortest matching suffix, ${x%%pattern} the longest
f=archive.tar.gz
echo ${f%.*} ${f%%.*}
p=/usr/local/bin/tool
echo ${p%/*} ${p%%/*}end
echo ${f%nomatch} ${f%gz} ${f%%*}x ${f%?}
echo ${f%[a-z]z}
