# '.' runs a file in the current shell: variables and functions it defines stay; its status is that of its last command
printf 'libvar=from-lib\nlibfn() { echo "libfn called with $1"; }\n' > lib.sh
. ./lib.sh
echo "libvar=$libvar"
libfn arg
printf 'echo "in st.sh"\nfalse\n' > st.sh
. ./st.sh; echo "status of '.': $?"
