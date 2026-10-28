# A failed redirection on a special built-in (':') makes a non-interactive POSIX shell exit; run in a subshell
# differs: dash (status 2) and bash --posix (status 1) exit the subshell; bash outside POSIX mode carries on and prints 'continued'
(: < nonexist; echo "continued")
echo "status $?"
