#!/usr/bin/env julia
# del2z <delta.z@aliyun.com>

include("wiki.jl")

run(`pwd`)
parsewiki("../../../../../Resources/Corpus/demo",
          "temp.txt")
#parsewiki("../../../../Resources/Corpus/zhwiki-latest-pages-articles6.xml-p6231444p6382070",
#          "temp.txt")

