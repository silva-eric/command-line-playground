# Aliases are expanded in non-interactive POSIX shells too, starting from the line after the alias command
# differs: bash outside POSIX mode does not expand aliases in scripts (expand_aliases is off), so 'hi' is not found (status 127)
alias hi='echo hello from an alias'
hi
echo "status $?"
unalias hi
