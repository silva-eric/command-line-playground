# exit runs the EXIT trap; inside the trap $? is the exit status, and the script keeps that status
trap 'echo "trap sees status $?"' EXIT
echo main
exit 4
