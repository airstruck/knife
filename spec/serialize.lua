local loadstring = _G.loadstring or _G.load

T('Given serialized data', function (T)
    local Serialize = require 'knife.serialize'

    local data = {
        a = 'a',
        b = 123,
        c = false,
        e = { a = 1 },
        f = function () end,
        g = { 3, 2, 1 },
    }

    data.d = data
    data.e[data] = 2

    local nan = tostring(0/0) == 'nan' and 0/0 or -(0/0)

    data.huge = math.huge
    data.tiny = -math.huge
    data.pnan = nan
    data.nnan = -nan

    local serialized = Serialize(data)

    T('When the data is deserialized', function (T)
        local d = loadstring(serialized)()

        T:assert(d.a == 'a', 'Then strings are stored')
        T:assert(d.b == 123, 'Then numbers are stored')
        T:assert(d.c == false, 'Then booleans are stored')
        T:assert(d.d == d, 'Then circular references are stored')
        T:assert(d.e.a == 1, 'Then tables are stored')
        T:assert(d.e[d] == 2, 'Then circular reference keys are stored')
        T:assert(d.f == nil, 'Then functions are not stored')
        T:assert(table.concat(d.g) == '321', 'Then arrays are stored')

        T:assert(d.huge == math.huge, 'Then infinity is stored correctly')
        T:assert(d.tiny == -math.huge, 'Then -infinity is stored correctly')
        T:assert(tostring(d.pnan) == 'nan', 'Then NaN is stored correctly')
        T:assert(tostring(d.nnan) == '-nan' or tostring(d.nnan) == 'nan',
        'Then -NaN is stored correctly') -- luajit doesn't print -nan
    end)

end)
