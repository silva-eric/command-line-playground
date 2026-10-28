# Prefix assignments before a function call are visible inside the function; afterwards the old value is back
# note: POSIX leaves it unspecified whether they persist after the function returns. bash 3.2 --posix keeps them ('after f: V=temp'); bash 5 --posix restores the old value like dash and bash
f() { echo "in f: V=$V"; }
V=global
V=temp f
echo "after f: V=$V"
