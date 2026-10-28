# A quoted reserved word in command position is not recognised: it is looked up as a command (status 127); a quoted name also stops an assignment
'if' true 2>/dev/null; echo "status $?"
\while 2>/dev/null; echo "status $?"
"done" 2>/dev/null; echo "status $?"
i\f=1 2>/dev/null; echo "status $?"
