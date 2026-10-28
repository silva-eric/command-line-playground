# Assignments happen left to right (later ones see earlier ones); the command's own words are expanded before the prefix assignments
a=1 b=$a; echo "b=$b"
x=old
x=new echo "echo saw $x"
c=1 d=$c sh -c 'echo "child got d=$d"'
