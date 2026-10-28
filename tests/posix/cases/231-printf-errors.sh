# A non-numeric argument to %d: a message on stderr, the number printed is what could be read (or 0), and the status is 1
# differs: for '12abc' bash 3.2 prints 0; dash prints 12, the value converted before the error, as POSIX requires (bash 5 also prints 12)
printf '%d\n' abc; echo "status $?"
printf '%d\n' 12abc; echo "status $?"
printf '%d|%d\n' 3 x; echo "status $?"
