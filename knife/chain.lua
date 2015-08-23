local function getNextLink (callbacks)

    local function getCallbackInvoker (index)
        return function (...)
            local callback = callbacks[index]
            if not callback then
                return
            end
            callback(getCallbackInvoker(index + 1), ...)
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
