# Here-documents inside a function, an if, a pipeline and a command substitution
f() {
  cat <<EOF
from function: $1
EOF
}
f arg
if true; then
  cat <<EOF
from if
EOF
fi
cat <<EOF | grep two
one
two
EOF
y=$(cat <<EOF
in substitution
EOF
)
echo "$y"
