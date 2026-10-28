# Reserved words are recognised after ; && || | ( and newlines, and after other reserved words
true; if true; then echo a; fi
false || if true; then echo b; fi
echo c | while read l; do echo "$l"; done
(if true; then echo d; fi)
if if true; then true; fi; then echo e; fi
! if false; then :; else false; fi && echo f
