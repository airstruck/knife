T('Given convoke', function (T)
    local Convoke = require 'knife.convoke'

    local cb = {}

    local function go ()
        for k, v in ipairs(cb) do
            v()
        end
        cb = {}
    end

    local function doStuff (arg1, arg2, callback)
        cb[#cb + 1] = function ()
            callback(arg1, arg2)
        end
    end

    T('When invoked with a callback', function (T)
        Convoke(function (continue, wait)
            doStuff(123, 456, continue())
            local r1, r2 = wait()
            T:assert(r1 == 123 and r2 == 456,
            'Then "wait" returns arguments passed to contination function')

            doStuff(234, 345, continue())
            local r1, r2 = wait()
            T:assert(r1 == 234 and r2 == 345,
            'Then "wait" returns arguments passed to contination function x2')
        end)()

        go()
    end)

    T('When multiple continues are present', function (T)
        Convoke(function (continue, wait)
            doStuff(123, 456, continue())
            doStuff(234, 345, continue())
            local r1, r2 = wait()
            T:assert(r1 == 234 and r2 == 345,
            'Then "wait" returns arguments from last invoked contination')
        end)()

        go()
    end)

    T('When invoked with multiple callbacks', function (T)
        Convoke(function (continue, wait)
            doStuff(123, 456, continue())
            local r1, r2 = wait()
            T:assert(r1 == 123 and r2 == 456,
            'Then "wait" returns arguments passed to contination function')
        end)(function (continue, wait)
            doStuff(234, 345, continue())
            local r1, r2 = wait()
            T:assert(r1 == 234 and r2 == 345,
            'Then "wait" returns arguments passed to contination function x2')
        end)()

        go()
    end)

    T('When invoked with a callback after running', function (T)
        local foo

        local c = Convoke(function (continue, wait)
            doStuff(123, 456, continue())
            local r1, r2 = wait()
            T:assert(r1 == 123 and r2 == 456,
            'Then "wait" returns arguments passed to contination function')
            foo = 1
        end)

        c()
        go()

        T:assert(foo == 1, 'Then the first callback runs')

        c(function (continue, wait)
            doStuff(234, 345, continue())
            local r1, r2 = wait()
            T:assert(r1 == 234 and r2 == 345,
            'Then "wait" returns arguments passed to contination function x2')
            foo = 2
        end)

        go()

        T:assert(foo == 2, 'Then the second callback runs')
    end)

end)
