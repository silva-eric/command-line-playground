# A case with no items or no match has status 0; otherwise it has the status of the last command run
false; case x in esac; echo "empty case: $?"
false; case x in y) ;; esac; echo "no match: $?"
false; case x in x) ;; esac; echo "empty body: $?"
case x in x) false;; esac; echo "body status: $?"
