# Saving and restoring stdout: exec 3>&1 >file ... exec 1>&3 3>&-
exec 3>&1 > f
echo "goes to the file"
exec 1>&3 3>&-
echo "back on stdout"
cat f
