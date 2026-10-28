# exit inside ( ) leaves only the subshell, whose status becomes that exit status
(exit 4); echo "status $?"
(echo a; exit 0; echo never); echo "status $?"
(false); echo "status $?"
set -- p q
(set -- x y z; echo "params in subshell: $#"); echo "params outside: $#"
