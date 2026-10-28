# A tilde-prefix in an ordinary word runs up to the first '/', so '~:' is the (unknown) login name ':' and stays as it is
# differs: bash (also with --posix) ends the tilde-prefix at ':' and prints /home/yourname: ; dash keeps ~:
echo ~: ~/
