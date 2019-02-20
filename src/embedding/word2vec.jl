#!/usr/bin/env julia
# del2z <delta.z@aliyun.com>

#module Word2Vec

using Flux: glorot_normal, ADAM, OneHotMatrix, OneHotVector
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

## model graph
embed_size = config["model"]["embed_size"]
W_emb = param(glorot_normal(embed_size, vocab_size))
W_out = param(glorot_normal(vocab_size, embed_size))
b_out = param(zeros(vocab_size))

function dataset end
function model end
function loss end

window = config["model"]["window"]
neg_scale = config["model"]["neg_scale"]
if config["method"] == "cbow"
    dataset(corpus::Vector{Vector{String}}) = begin
        Xs = Vector{OneHotMatrix}()
        Ys = Vector{OneHotVector}()
        for seq in corpus
            size(seq, 1) >= window || continue
            for k in 1:(size(seq, 1) - window + 1)
                tmp = seq[k:(k + window)]
                push!(Xs, nothing)
                push!(Ys, nothing)
            end
        end
        Xs, Ys
    end

    model(x::OneHotMatrix) = begin
        W_out * sum(W_emb * x, dims = 2) + b_out
    end

    loss(x::OneHotMatrix, y::OneHotVector) = begin
        model(x)
    end
else
    dataset(corpus::Vector{Vector{String}}) = begin
        Xs = Vector{OneHotMatrix}()
        Ys = Vector{OneHotVector}()
        Xs, Ys
    end

    model(x::OneHotVector) = begin
        W_out * W_emb * x + b_out
    end

    loss(x::OneHotVector, y::OneHotMatrix) = begin
    end
end

## training
Xs, Ys = dataset(corpus)
opt = ADAM(0.01)
tx, ty = (Xs[5], Ys[5])
evalcb = () -> @show loss(tx, ty)

Flux.train!(loss, params(W_emb, W_out, b_out), zip(Xs, Ys), opt,
            cb = throttle(evalcb, 30))

## testing

#end
