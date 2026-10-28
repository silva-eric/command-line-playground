# set -f turns pathname expansion off; set +f turns it back on
mkdir g && cd g || exit 1
touch a b
set -f; echo * ?
set +f; echo * ?
