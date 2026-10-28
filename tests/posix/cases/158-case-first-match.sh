# Only the first matching item runs (no fall-through); ';;' may be left out on the last item
case x in
  x) echo "first";;
  x) echo "second";;
  *) echo "default";;
esac
case y in x) echo one;; *) echo "last item without ;;"
esac
case z in z) echo "one line, no ;;"; esac
