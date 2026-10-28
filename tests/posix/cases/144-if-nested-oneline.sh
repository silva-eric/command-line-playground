# if statements nest and can be written on one line or inside $(...)
if true; then if false; then echo a; else echo b; fi; fi
if true; then echo c; fi; if false; then echo d; fi
x=$(if true; then echo e; fi); echo "$x"
