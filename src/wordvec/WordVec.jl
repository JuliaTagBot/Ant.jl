#!/usr/bin/env julia
#=
Word vector models
del2z <delta.z@aliyun.com>
=#
module WordVec

export nothing

struct VecModel{T <: Union{Polor, AbstractFloats}} <: Model
    id2word::Vector{String}
    word2id::Dict{String, Integer}
    embedding::Matrix{T}
end

include("word2vec.jl")
include("fasttext.jl")
include("glove.jl")

end
