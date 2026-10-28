# "$*" joins the parameters with the first character of IFS; with IFS empty they are joined with nothing; with IFS unset, with a space
set -- a b c
IFS=:; echo "$*"
IFS=',.'; echo "$*"
IFS=; echo "$*"
unset IFS; echo "$*"
IFS=' :'; echo "$*"
