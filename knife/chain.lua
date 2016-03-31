local function append (a, b)
    if type(b) == 'table' then
        for i = 1, #b do
            a[#a + 1] = b[i]
        end
    else
        a[#a + 1] = b
    end
    return a
end

local function getNextLink (callbacks)

    local function getCallbackInvoker (index)
        return function (...)
            local callback = callbacks[index]
            if not callback then
                return
            end
            local continue = getCallbackInvoker(index + 1)
            local returned = callback(continue, ...)
            if returned then
                returned(function (_, ...) continue(...) end)
            end
        end
    end

    local function nextLink (link, ...)
        if not link then
            return getCallbackInvoker(1)(...)
        end
        append(callbacks, link)
        return nextLink
    end

    return nextLink
end

return function (link)
    return getNextLink(append({}, link))
end
