# Brace expansion ({a,b} and {1..3}) is a bash extension, not POSIX
# differs: dash prints the braces as they are; bash (also with --posix) expands them
echo {a,b}c x{1..3}
echo "{a,b}" '{1..3}'
