#!/usr/bin/env julia
#=
Word vector models
del2z <delta.z@aliyun.com>
=#
module WordVec

using ..Gnar: Polar, Model
export nothing

struct VecModel{T <: Union{Polar, AbstractFloat}} <: Model
    id2word::Vector{String}
    word2id::Dict{String, Integer}
    embedding::Matrix{T}
end

include("word2vec.jl")
include("fasttext.jl")
include("glove.jl")

end # module
