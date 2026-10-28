# set -e and ( ) / { }: on the left of || -e is ignored inside them too; a failing subshell elsewhere exits the script
set -e
(false; echo "subshell continues") || echo never
{ false; echo "group continues"; } || echo never
(false)
echo never
