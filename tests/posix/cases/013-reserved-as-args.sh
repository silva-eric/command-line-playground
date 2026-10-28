# Reserved words are only special in command position; as arguments they are plain words
echo if then else elif fi do done case esac while until for in
echo { } ! function select time
x=if; echo $x
for in in in; do echo "loop variable named in: $in"; done
case in in in) echo "case word in, pattern in";; esac
