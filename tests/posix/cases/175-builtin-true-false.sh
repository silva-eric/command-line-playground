# true and false ignore their arguments and return 0 and 1
true; echo $?
false; echo $?
true ignored args; echo $?
false --ignored; echo $?
