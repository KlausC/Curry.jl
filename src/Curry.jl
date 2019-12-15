module Curry

export @curry, curry
export ldump, sldump
export generic_expr_walker, remove_lines!

"""
   @curry <function definition>

Define function methods with multiple argument lists.
The definition
    `@curry f(x)(y) = anything`
is equivalent with
    `f(x) = (y) -> anything`.
Each argument list supports all features of argument lists as keyword arguments
and ellipse.
"""
macro curry(ex)
    curry!(__source__, ex)
end

"""
    curry(expr::Expr[, line=LineNumberNode())

User interface to implementation of Expr transformation for [`@curry`](@ref).
The input expression is not modified.
"""
function curry(ex::Expr; line::LineNumberNode=LineNumberNode(0))
    curry!(line, deepcopy(ex))
end

# implementation.
function curry!(__source__::LineNumberNode, ex::Expr)
    ass = findex(isin([:(=),:function]), ex)
    ass != nothing && length(ass.args) == 2 || error("no function definition")
    cal = ass.args[1] # the lhs of = or f(..) part after function

    # if not :call, unmodified return
    cal isa Expr && cal.head == :call || return finish(__source__, ex)
    fna = cal.args[1] # potentially second :call for multiple arg lists

    # if not a second :call, unmodified return
    fna isa Expr && fna.head == :call || return finish(__source__, ex)

    # extract function arguments 
    far = length(cal.args) <= 2 ? cal.args[2] : :(($(cal.args[2:end]...),))
    blk = ass.args[2] # execution block of rhs
    ass.args[1] = fna # put second :call at top
    ass.args[2] = Expr(:block, Expr(:(->), far, blk)) # generate -> expr
    curry!(__source__, ex) # recursively build blocks for further :call s
end

isin(a) = x -> x in a

# add line info into first block and surround with esc.
function finish(__source__::LineNumberNode, ex::Expr)
    blk = findex(isequal(:block), ex)
    blk != nothing || return esc(ex)
    pushfirst!(blk.args, __source__)
    esc(ex)
end

# find expression with symbol as head in expression tree
function findex(pred::Function, ex::Expr)
    pred(ex.head) && return ex
    for ex in ex.args
        r = findex(pred, ex)
        r == nothing || return r
    end
    nothing
end
findex(::Function, ::Any) = nothing

"""
    ldump(:IO, ::Expr[, indent=string, delta=string])

Dump expression in a more readable list form.
Each expression is started with a new line `( head`
Each argument starts with a new line afetr indentation.
The keyword argument `indent` is the initial indentation.
The keyword argument `delta` is the additional indentation after the current.
"""
function ldump(io::IO, ex::Expr; indent="", delta="  ")
    indent = string(indent)
    println(io, indent, '(', ex.head)
    for a in ex.args
        delta = string(delta)
        ldump(io, a, indent=indent*delta, delta=delta)
    end
    println(io, indent, ')')
end

ldump(io::IO, ex::LineNumberNode; indent="", delta="") = nothing
ldump(io::IO, ex::Any; indent="", delta="") = println(io, indent, typeof(ex), ' ', ex)
ldump(ex::Any; indent="", delta="  ") = ldump(stdout, ex, indent=indent, delta=delta)

"""
    sldump(::Expr[, indent=string, delta=string])

    List dump of an expression. See [`ldump`](@ref). 
Store output in string.
"""
function sldump(ex::Any; indent="", delta="  ")
    io = IOBuffer()
    ldump(io, ex, indent=indent, delta=delta)
    String(take!(io))
end

"""
    Expression tree walker
"""
function generic_expr_walker(a::Function, ex::Expr)
    i = 1
    j = 0
    while i <= length(ex.args)
        arg = ex.args[i]
        argn = a(arg)
        if argn != nothing
            j += 1
            argn = something(argn)
            if j != i || argn != arg
                ex.args[j] = argn
            end
        end
        i += 1
    end
    resize!(ex.args, j)
    ex
end

identity_walker(ex::Expr) = generic_expr_walker(example_walker, ex)
example_walker(x) = Some(x)

remove_lines!(ex::Expr) = generic_expr_walker(remove_lines!, ex)
remove_lines!(::LineNumberNode) = nothing
remove_lines!(x) = Some(x)

end # module
