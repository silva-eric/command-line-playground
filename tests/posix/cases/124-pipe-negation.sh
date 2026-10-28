# ! negates the exit status of a whole pipeline
! true; echo $?
! false; echo $?
! true | false; echo $?
! (exit 3); echo $?
if ! false; then echo "negated in if"; fi
