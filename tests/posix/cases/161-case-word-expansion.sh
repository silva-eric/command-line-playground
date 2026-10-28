# The case word is expanded without field splitting or pathname expansion; patterns are expanded too (also tilde)
v='a b'
case $v in 'a b') echo "no splitting";; esac
case * in '*') echo "no globbing of the word";; esac
x=foo
case foo in $x) echo "pattern from a variable";; esac
case ~ in "$HOME") echo "tilde expanded in the word";; esac
case "$HOME/x" in ~/x) echo "tilde expanded in the pattern";; esac
