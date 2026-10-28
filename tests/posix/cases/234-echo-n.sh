# echo -n (a case about echo options): dash and bash both leave out the trailing newline
# note: on this Mac bash --posix prints -n as text (UNIX03 echo); bash --posix on Ubuntu treats -n as an option like dash
echo -n "no newline"; echo " <- joined"
echo -n; echo "empty -n"
