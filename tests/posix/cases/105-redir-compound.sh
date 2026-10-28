# Redirections apply to whole compound commands: { } ( ) if for case while
{ echo a; echo b; } > f
( echo c ) >> f
if true; then echo d; fi >> f
for i in e f; do echo $i; done >> f
case x in x) echo g;; esac >> f
while read l; do echo "read: $l"; done < f
