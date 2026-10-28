# Quotes in the word of ${x:-word} and in ${x#pattern}: inside double quotes, single quotes in a :- word are literal, but quotes in a # pattern still quote
unset u
printf '[%s]\n' ${u:-'a  b'} "${u:-'q'}" "${u:-"dq"}" ${u:-"x  y"}
v='a*b'
printf '[%s]\n' "${v#'a*'}" "${v#"a*"}" "${v#a*}" "${v#'a'}"
