#!/usr/bin/env julia
#=
Package Gnar
del2z <delta.z@aliyun.com>
=#

function loadwiki(fname::String)
    fin = open(fname, "r")
    doclist = Vector{String}[]
    count = 0
    doc = Vector{String}()
    IsKeep = false
    for line in eachline(fin)
        line = strip(line)
        if line == ""
            continue
        elseif startswith(line, "<doc id")
            IsKeep = true
            title = match(r"title=\"(.*)\"", line).captures[1]
            if startswith(title, "Wikipedia:") || startswith(title, "Help:")
                isKeep = false
                println("Exclude content of \"$title\"")
            end
        elseif startswith(line, "</doc>")
            if IsKeep && length(doc) > 0
                push!(doclist, copy(doc))
            end
            IsKeep = false
            empty!(doc)
        elseif IsKeep && isvalid(line)
            if startswith(line, "，") || startswith(line, "。") || (length(doc) > 0 && endswith(doc[end], "，"))
                doc[end] = doc[end] * clean(line)
            else
                push!(doc, lstrip(clean(line), ['，', '。']))
            end
        end
        count += 1
        if count > 5000
            break
        end
    end
    close(fin)
    doclist
end

function isvalid(str::AbstractString)
    reZh = r"[\u4e00-\u9fd5\uff0c]{8}"
    return match(reZh, str) != nothing && !startswith(str, "[[Category:") && !startswith(str, "[[File:")
end

function clean(str::AbstractString)
    str = replace(str, "（，" => "（")
    str = replace(str, "，）" => "）")
    str = replace(str, "「" => "“")
    str = replace(str, "」" => "”")
    str = replace(str, "“”" => "")
    str = replace(str, "-{}-" => "")
    str = replace(str, "《》" => "")
    str = replace(str, "（）" => "")
    str = replace(str, "()" => "")
    reCh = "\\u4e00-\\u9fd5a-zA-Z0-9·"
    str = replace(str, Regex("-{([$reCh]+)}-") => s"\1")
    if match(Regex("-{[$reCh;:\\- ]*zh-cn:[$reCh;:\\- ]*}-"), str) != nothing
        str = replace(str, Regex("-{[$reCh;:\\- ]*zh-cn:([$reCh]+)[$reCh;:\\- ]*}-") => s"\1")
    end
    if match(Regex("-{[$reCh;:\\- ]*zh-hans:[$reCh;:\\- ]*}-"), str) != nothing
        str = replace(str, Regex("-{[$reCh;:\\- ]*zh-hans:([$reCh]+)[$reCh;:\\- ]*}-") => s"\1")
    end
    if match(Regex("\\[\\[[$reCh]+\\]\\]"), str) != nothing
        str = replace(str, Regex("\\[\\[([$reCh]+)\\]\\]") => s"\1")
    end
    if match(Regex("\\[\\[[$reCh\\(\\) ]+\\|[$reCh\\(\\) ]+\\]\\]"), str) != nothing
        str = replace(str, Regex("\\[\\[[$reCh\\(\\) ]+\\|([$reCh\\(\\) ]+)\\]\\]") => s"\1")
    end
    str = replace(str, r"[。]{2,}" => "。")
    str = replace(str, r"[；]{2,}" => "；")
    # codice_, formula_
    str = lstrip(str, ['：', '？'])
    str = rstrip(str, ['：'])
    str
end

doclist = loadwiki("../../../../Resources/Corpus/zh_wiki.txt")
for doc in doclist
    println([x for x in doc if occursin("深化合作，研究和制定粤港澳大湾区", x)])
end

