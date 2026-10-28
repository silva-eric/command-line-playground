# A pattern that matches nothing is left as it is
mkdir g && cd g || exit 1
touch a
echo z* "[z]" [z] ?? a*
count() { echo $#; }
count z*
set -- nomatch*; echo "$1"
