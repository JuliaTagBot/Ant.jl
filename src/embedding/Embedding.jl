#!/usr/bin/env julia
#=
Word vector models
del2z <delta.z@aliyun.com>
=#
module Embedding

using ..Gnar: Polar, Model
export nothing

struct WordRep{T <: Union{Polar, AbstractFloat}} <: Model
    size::Integer
    dim::Integer
    id2word::Vector{String}
    word2id::Dict{String, Integer}
    embedding::Matrix{T}
end

function WordRep(fname::String)
end

function WordRep(wordlist::Vector{String})
end


include("word2vec.jl")
include("fasttext.jl")
include("glove.jl")

end # module
