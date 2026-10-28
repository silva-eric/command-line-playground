# The word in ${x:-word} gets tilde, parameter, command and arithmetic expansion, and only when it is used; unquoted, the result is split
unset u; s=set; y=why
echo ${u:-$y} ${u:-${y}2} ${u:-$(echo cmd)} ${u:-$((1+2))} ${u:-${u:-deep}} ${u:-~}
echo ${s:-$(echo "never runs" >&2)}
count() { echo $#; }
count ${u:-a b c} "${u:-a b c}" ${u:-} "${u:-}"
z='$HOME'; echo ${u:-$z}
