# -r -w -x follow the permission bits; -u and -k test the set-user-ID and sticky bits (run as a normal user: root would see different answers)
t() { label=$1; shift; test "$@"; printf '%s => %s\n' "$label" $?; }
touch f; chmod 000 f
t '-r f (000)' -r f
t '-w f (000)' -w f
chmod 400 f; t '-r f (400)' -r f; t '-w f (400)' -w f
chmod 200 f; t '-w f (200)' -w f; t '-x f (200)' -x f
chmod 700 f; t '-x f (700)' -x f
mkdir d; chmod 700 d; t '-x d (700)' -x d
touch s; chmod 4755 s; t '-u s (4755)' -u s; t '-u f' -u f
mkdir k; chmod 1777 k; t '-k k (1777)' -k k; t '-k d' -k d
