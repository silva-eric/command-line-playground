# A backslash outside quotes quotes the next character; quote removal then deletes the backslash
printf '[%s]\n' \a \$HOME \"x\" \'y\' a\ b \\ \; \| \&
x=val; printf '[%s]\n' \$x \${x} \*
