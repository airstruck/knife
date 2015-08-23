T('Given a function taking a callback', function (T)

    local Chain = require 'knife.chain'

    local function doStuff (a, b, callback)
        callback(a, b)
    end

    T('When Chain factory is called', function (T)

        local c1 = Chain(function (go)
            doStuff(2, 3, go)
        end)

        T:assert(type(c1) == 'function',
        'Then a chain is created')

        T('When the chain is invoked with a function arg', function (T)

            local resultA, resultB

            local c2 = c1(function (go, a, b)
                resultA = a
                resultB = b
                go()
            end)

            T:assert(type(c2) == 'function' and c1 == c2,
            'Then the chain is extended')

            T('When the chain is invoked with no args', function (T)

                c2()

                T:assert(resultA == 2 and resultB == 3,
                'Then the chain is executed')

            end)

        end)

    end)

end)
