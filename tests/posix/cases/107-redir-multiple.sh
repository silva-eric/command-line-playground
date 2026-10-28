# Several output redirections on one command: every file is created, the last one gets the output
echo x > a > b
echo "a:[$(cat a)] b:[$(cat b)]"
