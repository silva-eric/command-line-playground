# Single quotes keep every character literally: no expansion, and a backslash is an ordinary character
x=val
printf '[%s]\n' '$x' '${x}' 'a\nb' '"dq"' 'a  b' '`echo no`' '$(echo no)' '\'
printf '[%s]\n' 'it'\''s' ''
