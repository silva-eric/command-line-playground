# Tilde expansion in the word of ${x:-word}: expanded when unquoted, literal inside double quotes
unset u
echo ${u:-~} ${u:-~/x} "${u:-~}" "${u:-"~"}"
