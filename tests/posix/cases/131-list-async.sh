# '&' runs a command asynchronously; wait waits for every background job
{ sleep 0.2; echo background; } &
echo foreground
wait
echo "after wait: $?"
