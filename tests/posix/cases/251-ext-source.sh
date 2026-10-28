# source is a bash synonym for '.'; dash does not have it
# differs: dash says "source: not found" (status 127); bash runs the file
printf 'echo sourced\n' > lib.sh
source ./lib.sh
echo "status $?"
