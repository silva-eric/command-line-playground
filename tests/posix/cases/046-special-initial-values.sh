# Initial values: IFS is space, tab, newline; OPTIND is 1; HOME comes from the environment
case $IFS in ' 	
') echo "IFS is space tab newline";; *) echo "IFS is something else";; esac
echo "OPTIND=$OPTIND"
echo "HOME=$HOME"
