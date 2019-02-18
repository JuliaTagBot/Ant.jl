#!/usr/bin/env julia
# del2z <delta.z@aliyun.com>

module Word2Vec

using Flux
using JSON

const config = JSON.parsefile(joinpath(@__DIR__, "word2vec.json"))

W = param(rand())

end
