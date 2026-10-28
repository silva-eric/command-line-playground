# Defining a function again replaces it; a definition has status 0; a function can define another one
f() { echo one; }
f
f() { echo two; }
f
false; g() { :; }; echo "definition status: $?"
mk() { made() { echo "made by mk"; }; }
made 2>/dev/null || echo "made does not exist yet"
mk; made
