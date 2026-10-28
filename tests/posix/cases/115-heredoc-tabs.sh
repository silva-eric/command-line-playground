# <<- strips leading tab characters (not spaces) from each body line and from the delimiter line
x=val
cat <<-EOF
	one tab $x
		two tabs
    four spaces stay
  	spaces then a tab stay
	EOF
echo after
