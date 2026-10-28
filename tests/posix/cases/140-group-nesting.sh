# Groups and subshells nest
( { echo a; ( echo b ); } )
{ ( echo c ); { echo d; }; }
x=$( { echo e; } )
echo "$x"
( (echo f) )
