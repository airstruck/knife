local loadstring = _G.loadstring or _G.load
local tconcat = table.concat

local helperCache = {}

local function buildHelper (argCount)
    if helperCache[argCount] then
        return helperCache[argCount]
    end
    local argList1 = { 'f' }
    local argList2 = {}
    for index = 1, argCount do
        argList1[index + 1] = 'a' .. index
        argList2[index] = 'a' .. index
    end
    argList2[argCount + 1] = '...'
    local source = 'return function(' .. tconcat(argList1, ', ') ..
        ') return function(...) return f(' .. tconcat(argList2, ', ') ..
        ') end end'
    local helper = loadstring(source)()
    helperCache[argCount] = helper
    return helper
end

return function (func, ...)
    return buildHelper(select('#', ...))(func, ...)
end
