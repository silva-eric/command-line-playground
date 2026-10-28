# In pattern removal, quoted * ? are literal while unquoted ones (also from an unquoted $var) are pattern characters
x='a*b*c'
printf '[%s]\n' "${x%\**}" "${x%'*'*}" "${x#*\*}" "${x#"a*"}"
y=abc
printf '[%s]\n' "${y#'a?'}" "${y#a?}"
v='*abc'; star='*'
printf '[%s]\n' "${v#"$star"}" "${v##$star}" "${v#$star}"
