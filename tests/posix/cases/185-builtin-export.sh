# export marks variables for the environment of child processes; unexported variables are not passed on
export A=1
B=2
export C; C=3
sh -c 'echo "child: A=$A B=[$B] C=$C"'
