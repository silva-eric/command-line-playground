# A case item without the optional '(' inside $(...): valid POSIX
# differs: bash 3.2 stops at the ')' of the pattern and reports a syntax error; dash (and bash 4.0+, Ubuntu ships 5.2) print 'matched'
x=$(case y in y) echo matched;; esac)
echo "$x"
