# -ef (same file), and -nt / -ot with one file missing, so that no timing is involved
# differs: with a missing file bash says the existing file is newer (a -nt missing and missing -ot a are true), as POSIX.1-2024 specifies; dash says false
t() { label=$1; shift; test "$@"; printf '%s => %s\n' "$label" $?; }
touch a
t 'a -ef a' a -ef a
t 'a -ef ./a' a -ef ./a
t 'a -ef missing' a -ef missing
t 'a -nt missing' a -nt missing
t 'missing -ot a' missing -ot a
t 'missing -nt a' missing -nt a
