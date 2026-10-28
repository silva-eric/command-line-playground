# A comment inside $(...) may contain ')' without ending the substitution
# differs: bash 3.2 ends the substitution at the ')' in the comment (it prints an empty line and the raw text); bash 4.0+ (Ubuntu ships 5.2) prints after-comment like dash
m=$(# comment with )
echo after-comment)
printf '%s\n' "$m"
