# An argument that only looks like an assignment (opt=~/x) gets no tilde expansion in POSIX
# differs: bash outside POSIX mode expands a ~ after '=' in such arguments; bash --posix leaves it like dash
echo opt=~/x
