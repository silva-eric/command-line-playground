# set -e is ignored in if/while/until conditions, for commands before the last one in && and || lists, and for ! pipelines
set -e
if false; then echo no; else echo "if condition ok"; fi
while false; do :; done; echo "while condition ok"
until true; do :; done; echo "until condition ok"
false && echo no; echo "and-list ok"
false || echo "or-list ok"
! true; echo "negation ok"
echo end
