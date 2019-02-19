#!/usr/bin/env julia
# del2z <delta.z@aliyun.com>

module Word2Vec

using Flux
using JSON
using DataStructures

const config = JSON.parsefile(joinpath(@__DIR__, "word2vec.json"))

include("prepro.jl")

corpus = segment!(loaddata("corpus.txt"))
idx2word = genvocab(corpus, 1)
pushfirst!(idx2word, "<NIL>", "<UNK>")
word2idx = OrderedDict(zip(idx2word, 1:length(idx2word)))
@info length(corpus)
@info length(idx2word), typeof(idx2word)
@info length(word2idx), word2idx["<NIL>"], word2idx["<UNK>"]

# negative sampling
W_emb = param(rand(length(idx2word), config["model"]["embed_size"]))
W_out = param(rand())
b_out = param(rand())

model = nothing

function loss()
end

function train!()
end

function test()
end

end
