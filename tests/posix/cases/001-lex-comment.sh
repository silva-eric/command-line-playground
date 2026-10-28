# Comments: an unquoted '#' at the start of a word starts a comment up to the end of the line; elsewhere it is literal
echo one # this part is a comment
echo two#three
echo 'four # five' "six # seven" eight\#nine
x=ten#; echo $x
# a whole-line comment
	# an indented comment (after a tab)
echo $# args, ${#x} chars
echo end #
