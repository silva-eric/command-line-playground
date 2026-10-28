# shift drops the first n parameters (default 1); shift 0 does nothing
set -- a b c d e
shift; echo "$# [$*]"
shift 2; echo "$# [$*]"
shift 0; echo "$# [$*]"
shift 2; echo "$# [$*]"
set -- a b c d e f g h i j k l; shift 10; echo "$# [$*]"
