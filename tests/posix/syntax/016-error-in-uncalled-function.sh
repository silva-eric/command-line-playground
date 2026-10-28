# A syntax error inside a function that is never called still stops the script when the definition is read
echo before
f() {
  if true; then echo x
}
echo after
