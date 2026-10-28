# echo -e (a case about echo options): bash takes -e as an option; dash has no options except -n and prints it
# differs: dash prints "-e" as text (and interprets the escape anyway); bash treats -e as an option that turns on escapes
# note: on this Mac bash --posix prints -e as text, like dash
echo -e 'a\tb'
echo -e
