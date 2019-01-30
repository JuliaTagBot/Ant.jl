#!/usr/bin/env julia
#=
#  Copyright by del2z <delta.z@aliyun.com>
#  Licensed under LGPL-v3.0 (https://www.gnu.org/licenses/lgpl-3.0.en.html)
=#

include("wiki.jl")

run(`pwd`)
parsewiki("../../../Corpora/wiki/demo",
          "temp.txt")
#parsewiki("../../../../Resources/Corpus/zhwiki-latest-pages-articles6.xml-p6231444p6382070",
#          "temp.txt")

