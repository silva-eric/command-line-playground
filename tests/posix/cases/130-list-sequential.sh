# ';' and newlines both separate commands; a trailing ';' is allowed
echo a; echo b; false; echo "after false: $?"
echo c
echo d;
false; true; echo $?
