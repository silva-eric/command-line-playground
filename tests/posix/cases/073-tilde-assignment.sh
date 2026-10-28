# In an assignment a tilde right after '=' or after an unquoted ':' is expanded; in an ordinary argument only at the start
p=~/bin:~/lib
echo "$p"
x=a~:~; echo "$x"
echo a:~/x
