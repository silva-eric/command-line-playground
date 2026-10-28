# > creates or truncates a file, >> appends; a redirection without a command creates the file
echo one > f; echo two > f; cat f
echo three >> f; cat f
> empty; [ -f empty ] && [ ! -s empty ] && echo "empty file created"
>> new; [ -f new ] && echo "append also creates the file"
echo hidden > /dev/null
