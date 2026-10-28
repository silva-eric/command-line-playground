# Operators are recognised without blanks around them: ; && || | > >> < ( ) and { } after ';'
echo a;echo b
true&&echo and||echo or
false||echo or2
echo piped|cat
echo file>f;cat<f
echo more>>f;cat f
(echo sub)
{ echo grp;}
