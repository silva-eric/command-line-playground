# ${#x} is the length of the value in characters; ${#} is the number of positional parameters
x=hello; e=; unset u
echo ${#x} ${#e} ${#u}
y="a b  c"; echo ${#y}
n=12345; echo ${#n}
set -- 1 22 333; echo ${#} ${#2}
