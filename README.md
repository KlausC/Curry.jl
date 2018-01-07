# Curry

This package demonstrates the syntax variant of currying.
For theoretical background and history: [Currying](https://en.wikipedia.org/wiki/Currying).

Essentially it allowe us to define
```
    f(x)(y)(z) = f_old(x,y,z)
    
meaning the same as

    f(x) = (y) -> ( (z) -> f_old(x,y,z) )
```    


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

julia> Curry.curry(LineNumberNode(1), :(f(x)(y,z) = nothing))
:($(Expr(:escape, :(f(x) = begin
          #= line 1 =#
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

julia> ldump(Curry.curry(LineNumberNode(0), :(f(x)(y,z) = nothing)))
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


