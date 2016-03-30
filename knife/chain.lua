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

    local function nextLink (callback, ...)
        if not callback then
            return getCallbackInvoker(1)(...)
        end
        callbacks[#callbacks + 1] = callback
        return nextLink
    end

    return nextLink
end

return function (callback)
    local callbacks = { callback }
    return getNextLink(callbacks)
end
