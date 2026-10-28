# ${x-word} uses word when x is unset; ${x:-word} also when x is empty; x itself is not changed
unset u; e=; s=set
echo "[${u-w}] [${e-w}] [${s-w}]"
echo "[${u:-w}] [${e:-w}] [${s:-w}]"
echo "[${u-}] [${u:-}] [${u-$s}]"
echo "u is still [${u-unset}], e is still [$e]"
