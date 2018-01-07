# Curry

This package demonstrates the syntax variant of currying.
For theoretical background and history: [Currying](https://en.wikipedia.org/wiki/Currying).

Essentially it allows to define
```
    @curry f(x)(y)(z) = F(x,y,z)
    
meaning the same as

    f = (x) -> (y) -> (z) -> F(x,y,z)
and
    f(x) = (y) -> (z) -> F(x,y,z)
```
The argument lists may be tuples and contain ellipses ... after the final argument and
keyword arguments.

## usage

```
julia> using Curry

julia> @curry f(x)(y) = x + y
f (generic function with 1 method)

julia> f(42)
#1 (generic function with 1 method)

julia> f(42)(1)
43

julia> using Unicode

julia> @curry function g(trans::Function)(s::AbstractString...)
           trans.(s)
       end
g (generic function with 1 method)

julia> all_upper = g(uppercase)
#5 (generic function with 1 method)

julia> all_upper("abc", "dEf")
("ABC", "DEF")
```

The following example shows, how the parsed expression is transformed.

```
julia> :(f(x)(y,z) = nothing)
:((f(x))(y, z) = begin
          #= REPL[21]:1 =#
          nothing
      end)

julia> curry(:(f(x)(y,z) = nothing))
:($(Expr(:escape, :(f(x) = begin
          #= line 0 =#
          (y, z)->begin
                  #= REPL[22]:1 =#
                  nothing
              end
      end))))
```

The function `ldump` is also contained in the package and prints `Expr` objects
in a list form.

```
julia> ldump(:(f(x)(y,z) = nothing))
(=
  (call
    (call
      Symbol f
      Symbol x
    )
    Symbol y
    Symbol z
  )
  (block
    Symbol nothing
  )
)

julia> ldump(curry(:(f(x)(y,z) = nothing)))
(escape
  (=
    (call
      Symbol f
      Symbol x
    )
    (block
      (->
        (tuple
          Symbol y
          Symbol z
        )
        (block
          Symbol nothing
        )
      )
    )
  )
)

```


