T('Given a function to bind', function (T)

    local Bind = require 'knife.bind'

    local a, b, c, d, e

    local function doStuff (arg1, arg2, arg3, arg4)
        a, b, c, d = arg1, arg2, arg3, arg4
        e = 5
    end

    T('When bound and executed', function (T)
        local bound = Bind(doStuff, 1, 2)
        assert(a == nil and b == nil and c == nil and d == nil)
        bound()
        T:assert(a == 1 and b == 2 and c == nil,
        'Then arguments were bound correctly')
    end)

    T('When bound and executed with more args', function (T)
        local bound = Bind(doStuff, 1, 2)
        assert(a == nil and b == nil and c == nil and d == nil)
        bound(3, 4)
        T:assert(a == 1 and b == 2 and c == 3 and d == 4,
        'Then arguments were bound correctly')
    end)

    T('When bound with no args and executed', function (T)
        local bound = Bind(doStuff)
        assert(e == nil)
        bound()
        T:assert(e == 5,
        'Then bound function works correctly')
    end)

end)
