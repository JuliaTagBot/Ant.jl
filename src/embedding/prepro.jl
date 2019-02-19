#!/usr/bin/env julia
# del2z <delta.z@aliyun.com>

using StatsBase

" Load raw corpus in `Vector{String}` "
function loaddata(fname::AbstractString)
    corpus = Vector{String}()
    open(fname, "r") do fin
        for line in eachline(fin)
            length(line) > 10 && push!(corpus, strip(line))
        end
    end
    corpus
end

" Segment words in corpus "
function segment!(corpus::Vector{<:AbstractString})
    newcorp = Vector{Vector{String}}()
    for k in 1:length(corpus)
        push!(newcorp, string.(collect(corpus[k])))
    end
    newcorp
end

" Generate vocabulary from corpus "
function genvocab(corpus::Vector{Vector{String}}, mincount::Integer = 0)
    wordcount = Dict{String,Int64}()
    for k in 1:length(corpus)
        addcounts!(wordcount, corpus[k])
    end
    (mincount <= 0) ? collect(keys(wordcount)) :
    filter(w -> wordcount[w] >= mincount, collect(keys(wordcount)))
end
