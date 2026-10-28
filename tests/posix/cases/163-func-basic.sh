# Functions: definition and call with arguments; $1.. and $# belong to the call and are restored afterwards
f() { echo "f got $#: $*"; }
set -- outer1 outer2
f a b c
echo "after: $# $*"
g()
{
  echo "g with the body on its own lines: $1"
}
g x
