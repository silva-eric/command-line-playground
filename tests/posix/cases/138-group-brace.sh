# { } groups commands in the current shell: changes stay, and the group can be piped or redirected as a whole
x=1
{ x=2; echo "in group"; }
echo "x=$x"
{ echo a; echo b; } | sort -r
{ echo c
  echo d
}
