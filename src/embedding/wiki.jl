#!/usr/bin/env julia
#=
Package Gnar
del2z <delta.z@aliyun.com>
=#

import Base: replace
using DataStructures: Stack

UniEn = "\\u0000-\\uffff"
UniCJK = "\\u0000-\\uffff"

function parsewiki(fxml::String, ftxt::String)
    fin = open(fxml, "r")
    fout = open(ftxt, "w")
    reTitle = Regex("<title>([$UniCJK]+)</title>")
    reNs = r"<ns>([\-\d]+)</ns>"
    reId = r"<id>(\d+)</id>"
    reText1 = Regex("<text xml:space=\"preserve\">([$UniCJK]*)")
    reText2 = Regex("([$UniCJK]*)</text>")
    InPage = IsKeep = InText = false
    title = id = content = ""
    for line in eachline(fin)
        line = strip(line)
        if line == "<page>"
            InPage = true
        elseif line == "</page>"
            content = clean(content)
            length(content) > 0 || (IsKeep = false)
            (InPage && IsKeep) && write(fout, "<doc id=\"$id\" title=\"$title\">\n$content\n</doc>\n")
            InPage = false
            title = ""
            id = ""
            content = ""
        end
        if title == "" && match(reTitle, line) != nothing
            title = match(reTitle, line).captures[1]
            println("title: ", match(reTitle, line).captures[1])
        elseif match(reNs, line) != nothing
            IsKeep = match(reNs, line).captures[1] == "0"
        elseif id == "" && match(reId, line) != nothing
            id = match(reId, line).captures[1]
            println("id: ", match(reId, line).captures[1])
        elseif match(reText1, line) != nothing && match(reText2, line) === nothing
            InText = true
            content = match(reText1, line).captures[1] * "\n"
        elseif match(reText2, line) != nothing && match(reText1, line) === nothing
            content *= match(reText2, line).captures[1]
            InText = false
        elseif InText
            content *= line * "\n"
        end
    end
    close(fin)
    close(fout)
end

function clean(str::AbstractString)
    # remove elements with bracelets
    str = replace(str, "&lt;math", "&lt;/math&gt;", " ")
    pair = search(str, "{{", "}}")
    bracefields = ["Infobox", "Taxobox", "Notability", "onesource", "More footnotes", "DEFAULTSORT"]
    while !isempty(pair)
        leftindex = collect(keys(pair))[1]
        rightindex = pop!(pair, leftindex) + length("}}") - 1
        for field in bracefields
            if startswith(str[leftindex + length("{{"):end], field)
                str = replace(str, leftindex, rightindex, "")
                update!(pair, leftindex, rightindex, rlen = 0)
                break
            end
        end
    end

    pair = search(str, "\\[\\[", "\\]\\]")
    bracketfields = ["Category"]
    while !isempty(pair)
        leftindex = collect(keys(pair))[1]
        rightindex = pop!(pair, leftindex) + length("]]") - 1
        for field in bracketfields
            if startswith(str[leftindex + length("[["):end], field)
                str = replace(str, leftindex, rightindex, "")
                update!(pair, leftindex, rightindex, rlen = 0)
                break
            end
        end
    end

    str = replace(str, "&lt;ref&gt;", "&lt;/ref&gt;", "")
    #=
    str = replace(str, "&lt;ref", "/&gt;", "")
    str = replace(str, "&lt;!--", "--&gt;", "")
    str = replace(str, "{\\| class", "\\|}", "")
    str = replace(str, Regex("{{reflist}}[$UniCJK]*") => "")
    str = replace(str, Regex("&lt;references /&gt;[$UniCJK]*") => "")
    str = replace(str, r"\n==[^\n]+==\n" => "")
    str = replace(str, r"\n===[^\n]+===\n" => "")
    str = replace(str, r"\n[,.:' ，。：]*\n", "\n")
    str = replace(str, r"^\n|\n$" => "")
    str = replace(str, r"'{2,}" => "")
    str = replace(str, Regex("\\n\\*[$UniCJK]{0,50}\\n"), "\n")
    =#
    return str
end


" Search paired patterns and return matched offsets "
function search(s::AbstractString, left::AbstractString, right::AbstractString)
    pair = Dict{Int, Int}()
    match(Regex("$left"), s) === nothing && return pair
    stack = Stack{Int}()
    for m in eachmatch(Regex("($left|$right)"), s)
        if match(Regex("$left"), m.match) != nothing
            push!(stack, m.offset)
        elseif match(Regex("$right"), m.match) != nothing
            !isempty(stack) && push!(pair, pop!(stack) => m.offset)
        else
            println("Incorrect substring '$(m.match)' matching patterns ('$left', '$right')")
        end
    end
    return pair
end


" Replace `s[leftindex:rightindex]` by `r` "
function Base.replace(s::AbstractString, leftindex::Int, rightindex::Int, r::AbstractString)
    s[1:thisind(s, leftindex - 1)] * r * s[thisind(s, rightindex + 1):end]
end


" Replace all substrings matching `pat` with `r` "
function Base.replace(s::AbstractString, pat::Regex, r::AbstractString)
    while true
        match(pat, s) === nothing && break
        s = replace(s, pat => r)
    end
    return s
end


" Replace all substrings between `left` and `right` patterns with `r` "
function Base.replace(s::AbstractString, left::AbstractString, right::AbstractString, r::AbstractString)
    pair = search(s, left, right)
    rightlen = length(right) - count(c -> c == '\\', right)
    rlen = length(r)
    while !isempty(pair)
        leftindex = collect(keys(pair))[1]
        rightindex = pop!(pair, leftindex) + rightlen - 1
        s = replace(s, leftindex, rightindex, r)
        update!(pair, leftindex, rightindex, rlen = rlen)
    end
    return s
end


" Update paired dict after replacement "
function update!(pair::Dict{Int, Int}, leftindex::Int, rightindex::Int; rlen::Int = 0)
    plen = rightindex - leftindex + 1
    for (k, v) in collect(pair)
        if k < leftindex && v < leftindex
            continue
        elseif k < leftindex && v > rightindex
            pair[k] = v - plen + rlen
        elseif k >= leftindex && v <= rightindex
            delete!(pair, k)
        elseif k > rightindex && v > rightindex
            delete!(pair, k)
            pair[k - plen + rlen] = v - plen + rlen
        else
            println("Mismatched paired pattern ($k, $v)")
        end
    end
end

run(`pwd`)
parsewiki("../../../../../Resources/Corpus/demo",
          "temp.txt")
#parsewiki("../../../../Resources/Corpus/zhwiki-latest-pages-articles6.xml-p6231444p6382070",
#          "temp.txt")
