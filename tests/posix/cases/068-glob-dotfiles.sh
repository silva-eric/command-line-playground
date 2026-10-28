# A leading '.' must be matched by a literal '.', also after a '/'; .[!.]* skips . and ..
mkdir g && cd g || exit 1
mkdir d && touch .a .b c d/.e d/f
echo .[ab]
echo d/*
echo d/.[e]
echo *
echo .[!.]*
