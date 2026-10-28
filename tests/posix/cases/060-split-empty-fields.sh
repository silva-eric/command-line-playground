# Unquoted expansions that are empty give no field, even between other words, unless something quoted is attached
a=; b=x
count() { echo $#; }
count $a $b $a
count "$a" $b "$a"
count $a$a
count ${a}${b}${a}
count $a""
