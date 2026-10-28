# Integer comparisons -eq -ne -gt -ge -lt -le, also with negative numbers and leading zeros
t() { label=$1; shift; test "$@"; printf '%s => %s\n' "$label" $?; }
t '1 -eq 1' 1 -eq 1
t '1 -ne 2' 1 -ne 2
t '2 -gt 1' 2 -gt 1
t '2 -ge 2' 2 -ge 2
t '1 -lt 2' 1 -lt 2
t '3 -le 2' 3 -le 2
t '-5 -lt -3' -5 -lt -3
t '01 -eq 1' 01 -eq 1
t '01 = 1' 01 = 1
t '10 -gt 9' 10 -gt 9
t '10 > 9 (string)' 10 \> 9
