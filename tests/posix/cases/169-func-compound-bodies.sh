# A function body can be any compound command: ( ) if for case, not only { }
s() ( x=inner; echo "subshell body: $x" )
x=outer; s; echo "x is still $x"
i() if [ "$1" = yes ]; then echo "if body: yes"; else echo "if body: no"; fi
i yes; i no
l() for k in 1 2; do echo "for body $k"; done
l
c() case $1 in a) echo "case body a";; *) echo "case body other";; esac
c a; c b
