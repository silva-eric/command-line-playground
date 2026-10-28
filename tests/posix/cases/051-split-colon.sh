# IFS=: (not whitespace): every ':' ends a field, so '::' gives an empty field, but a final ':' does not start a new one
IFS=:
count() { echo $#; }
v='a::b:'; count $v; printf '[%s]' $v; echo
v=':a'; count $v; printf '[%s]' $v; echo
v=':'; count $v
v='::'; count $v
v='a'; count $v
