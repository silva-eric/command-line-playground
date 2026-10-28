# A prefix assignment on an external command goes into that command's environment only and does not stay in the shell
X=outer
X=inner sh -c 'echo "child sees X=$X"'
echo "shell keeps X=$X"
unset Y
Y=temp sh -c 'echo "child sees Y=$Y"'
echo "Y afterwards: [${Y-unset}]"
Z=1 cat /dev/null; echo "Z afterwards: [${Z-unset}]"
