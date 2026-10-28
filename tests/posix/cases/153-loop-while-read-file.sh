# A while read loop reading a file with '< file' after done
printf 'alpha 1\nbeta 2\ngamma 3\n' > data
while read name num; do echo "$num:$name"; done < data
count=0
while read line; do count=$((count + 1)); done < data
echo "lines=$count"
