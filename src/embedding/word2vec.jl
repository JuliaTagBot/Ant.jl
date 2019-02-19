#!/usr/bin/env julia
# del2z <delta.z@aliyun.com>

#module Word2Vec

using Flux
using JSON
using DataStructures

const config = JSON.parsefile(joinpath(@__DIR__, "word2vec.json"))

include("prepro.jl")

corpus = segment!(loaddata("corpus.txt"))
idx2word = genvocab(corpus, 1)
pushfirst!(idx2word, "<NIL>", "<UNK>")
vocab_size = length(idx2word)
word2idx = OrderedDict(zip(idx2word, 1:vocab_size))
@info length(corpus)
@info length(idx2word), typeof(idx2word)
@info length(word2idx), word2idx["<NIL>"], word2idx["<UNK>"]

# negative sampling
embed_size = config["model"]["embed_size"]
W_emb = param(rand(vocab_size, embed_size))
W_out = param(rand(embed_size, vocab_size))
b_out = param(rand(vocab_size))

function model end

if config["method"] == "cbow"
    model(x) = nothing
else
    model(x) = nothing
end

function loss()
end

function train!()
end

function test()
end

#end
