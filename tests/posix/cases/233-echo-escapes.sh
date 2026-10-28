# echo with backslashes (a case about echo itself): dash's echo always interprets escapes such as \t \n \c \\
# differs: dash's echo follows XSI and interprets backslash escapes; bash's built-in echo prints them literally (unless -e or xpg_echo)
# note: on this Mac bash --posix behaves like dash here (Apple builds bash with a UNIX03 echo in POSIX mode); bash --posix on Ubuntu prints the backslashes literally
echo 'tab:\there'
echo 'two\nlines'
echo 'back\\slash'
echo 'stop\cignored'
echo after
