# set -o name and set +o name are long forms of the single-letter options; letters can be combined (set -fu)
set -o noglob; case $- in *f*) echo "noglob on";; esac
set +o noglob; case $- in *f*) ;; *) echo "noglob off";; esac
set -o errexit; case $- in *e*) echo "errexit on";; esac
set +o errexit
set -o nounset; case $- in *u*) echo "nounset on";; esac
set +o nounset
set -fu; case $- in *f*u*|*u*f*) echo "combined -fu";; esac; set +fu
