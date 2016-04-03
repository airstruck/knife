local function Invoker (links, index)
    return function (...)
        local link = links[index]
        if not link then
            return
        end
        local continue = Invoker(links, index + 1)
        local returned = link(continue, ...)
        if returned then
            returned(function (_, ...) continue(...) end)
        end
    end
end
    
return function (...)
    local links = { ... }

    local function chain (...)
        if not (...) then
            return Invoker(links, 1)(select(2, ...))
        end
        local offset = #links
        for index = 1, select('#', ...) do
            links[offset + index] = select(index, ...)
        end
        return chain
    end

    return chain
end

