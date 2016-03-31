T('Given a function taking a callback', function (T)

    local Chain = require 'knife.chain'

    local function doStuff (a, b, callback)
        callback(a, b)
    end
    
    local invoke = {}
    
    local function funcThatReturnsChain (x)
        local chain = Chain(function (go) go(x * 2) end)
        invoke[#invoke + 1] = function () chain() end
        return chain
    end
    
    T('When multiple functions are linked to a chain', function (T)
        local c = Chain(
            function (go, x)
                T:assert(x == 123, 'Then args are passed')
                go(456)
            end,
            function (go, x)
                T:assert(x == 456, 'Then args are passed x2')
                go(111)
            end
        )
        c(
            function (go, x)
                T:assert(x == 111, 'Then args are passed x3')
                go(222)
            end,
            function (go, x)
                T:assert(x == 222, 'Then args are passed x4')
            end
        )
        c(nil, 123)
    end)
    
    T('When a function that returns a chain is called', function (T)
        funcThatReturnsChain(123)(function (go, x)
            T:assert(x == 246, 'Then args are passed')
            return funcThatReturnsChain(33)
        end)(function (go, x)
            T:assert(x == 66, 'Then more chains can be returned')
            return funcThatReturnsChain(321)
        end)(function (go, x)
            T:assert(x == 642, 'Then more chains can be returned x2')
            go(111)
        end)(function (go, x)
            T:assert(x == 111, 'Then continue function still works')
        end)
        for _, f in ipairs(invoke) do
            f()
        end
    end)

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
