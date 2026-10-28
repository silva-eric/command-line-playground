# Recursive functions, using positional parameters and command substitution instead of local variables
fact() {
  if [ "$1" -le 1 ]; then echo 1
  else echo $(( $1 * $(fact $(( $1 - 1 ))) ))
  fi
}
fact 5
fib() { if [ $1 -lt 2 ]; then echo $1; else echo $(( $(fib $(($1 - 1))) + $(fib $(($1 - 2))) )); fi; }
fib 7
