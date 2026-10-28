# The output of an unquoted $(...) is split with IFS like a variable
count() { echo $#; }
count $(printf 'a b\nc')
count "$(printf 'a b\nc')"
IFS='
'
count $(printf 'line one\nline two\n')
