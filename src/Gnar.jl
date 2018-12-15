#!/usr/bin/env julia
#=
Package Gnar
del2z <delta.z@aliyun.com>
=#
module Gnar

export Polor, Model

include("Struct.jl")

include("data/Data.jl")
include("wordvec/WordVec.jl")

end # module
