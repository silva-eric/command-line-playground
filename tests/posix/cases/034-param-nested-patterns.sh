# Patterns can contain expansions: ${x%"${x#?}"} is the first character, ${x#"${x%?}"} the last
x=hello
echo "${x%"${x#?}"}" "${x#"${x%?}"}"
d=/a/b/c.txt; b=${d##*/}
echo "${d%/*}" "$b" "${b%.*}" "${b##*.}"
