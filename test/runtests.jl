using Curry
using Test

# write your own tests here

@curry f(x)(y) = x + y
f42 = f(42)
@test f42 isa Function
@test f42(1) == 43

@test sldump( :(a + b) ) == "(call\n  Symbol +\n  Symbol a\n  Symbol b\n)\n"
