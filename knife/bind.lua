local loadstring = _G.loadstring or _G.load
local tconcat = table.concat

local helperCache = {}

local function buildHelper (argCount)
    if helperCache[argCount] then
        return helperCache[argCount]
    end
    local argList = {}
    for index = 1, argCount do
        argList[index] = 'a' .. index
    end
    local sep = argCount > 0 and ', ' or ''
    local source = 'return function(f' .. sep .. tconcat(argList, ', ') ..
        ') return function(...) return f(' .. tconcat(argList, ', ') ..
        sep .. '...) end end'
    local helper = loadstring(source)()
    helperCache[argCount] = helper
    return helper
end

return function (func, ...)
    return buildHelper(select('#', ...))(func, ...)
end
