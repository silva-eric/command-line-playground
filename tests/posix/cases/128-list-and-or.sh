# && runs the next command only after success, || only after failure; both have equal precedence and group left to right
true && echo yes
false && echo no
false || echo alt
true || echo never
false && echo x || echo y
true || false && echo z
false || false || echo third
