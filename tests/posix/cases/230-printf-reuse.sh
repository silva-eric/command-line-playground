# The format is reused until the arguments run out; missing arguments count as empty strings or zero
printf '%s=%s\n' a 1 b 2 c
printf '[%s|%d|%s]\n'
printf '%d %s\n' 1 a 2
printf 'no conversion\n' extra args
