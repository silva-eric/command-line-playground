# Tilde expansion: an unquoted ~ at the start of a word becomes $HOME; quoted or mid-word tildes stay; an empty HOME gives an empty string
echo ~ ~/docs ~/
echo "~" '~' \~ a~b "~/q" ~/a~b
HOME=/other; echo ~ ~/x
HOME=; echo "[$(echo ~)]"
