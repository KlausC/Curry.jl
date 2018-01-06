module Curry

export curry, @curry
export ldump, sldump

macro curry(ex)
    curry(__source__, ex)
end

function curry(__source__::LineNumberNode, ex::Expr)
    ass = findex(occursin([:(=),:function]), ex)
    ass != nothing && length(ass.args) == 2 || error("no function definition")
    cal = ass.args[1]
    cal isa Expr && cal.head == :call || return finish(__source__, ex)
    fna = cal.args[1]
    fna isa Expr && fna.head == :call || return finish(__source__, ex)
    far = length(cal.args) <= 2 ? cal.args[2] : :(($(cal.args[2:end]...),))
    blk = ass.args[2] 
    ass.args[1] = fna
    ass.args[2] = Expr(:block, Expr(:(->), far, blk))
    curry(__source__, ex)
end

function finish(__source__::LineNumberNode, ex::Expr)
    blk = findex(equalto(:block), ex)
    blk != nothing || return esc(ex)
    pushfirst!(blk.args, __source__)
    esc(ex)
end

function findex(pred::Function, ex::Expr)
    pred(ex.head) && return ex
    for ex in ex.args
        r = findex(pred, ex)
        r == nothing || return r
    end
    nothing
end
findex(::Function, ::Any) = nothing

function ldump(io::IO, ex::Expr, indent::AbstractString="")
    println(io, indent, '(', ex.head)
    for a in ex.args
        ldump(io, a, indent * "  ")
    end
    println(io, indent, ')')
end

ldump(io::IO, ex::LineNumberNode, indent::AbstractString="") = nothing
ldump(io::IO, ex::Any, indent::AbstractString="") = println(io, indent, typeof(ex), ' ', ex)
ldump(ex::Any, indent::AbstractString="") = ldump(STDOUT, ex, indent)

function sldump(ex::Any, indent::AbstractString="")
    io = IOBuffer()
    ldump(io, ex, indent)
    String(take!(io))
end

end # module
