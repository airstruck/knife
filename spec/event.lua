T('Given event module is loaded', function (T)
    local Event = require 'knife.event'
    Event.handlers = {}

    T('When a handler is registered', function (T)
        local eventArg
        local fooHandler = Event.on('foo', function (x) eventArg = x end)

        T('When the event fires', function (T)
            assert(eventArg == nil)
            Event.dispatch('foo', 123)
            T:assert(eventArg == 123, 'Then the handler runs')
        end)

        T('When the handler is removed and the event fires', function (T)
            fooHandler:remove()
            assert(eventArg == nil)
            Event.dispatch('foo', 123)
            T:assert(eventArg == nil, 'Then the handler does not run')

            T('When the handler is removed again', function (T)
                fooHandler:remove()
                T:assert(true, 'Then no error occurs')
            end)
        end)

        T('When a second handler is registered', function (T)
            local eventArg2
            local fooHandler2 = Event.on('foo', function (x) eventArg2 = x end)

            T('When the event fires', function (T)
                assert(eventArg == nil and eventArg2 == nil)
                Event.dispatch('foo', 123)
                T:assert(eventArg == 123, 'Then the first handler runs')
                T:assert(eventArg2 == 123, 'Then the second handler runs')
            end)

            T('When the first handler is removed and the event fires', function (T)
                fooHandler:remove()
                assert(eventArg == nil and eventArg2 == nil)
                Event.dispatch('foo', 123)
                T:assert(eventArg == nil, 'Then the first handler does not run')
                T:assert(eventArg2 == 123, 'Then the second handler runs')
            end)

            T('When the second handler is removed and the event fires', function (T)
                fooHandler2:remove()
                assert(eventArg == nil and eventArg2 == nil)
                Event.dispatch('foo', 123)
                T:assert(eventArg == 123, 'Then the first handler runs')
                T:assert(eventArg2 == nil, 'Then the second handler does not run')
            end)

            T('When the handler is registered again', function (T)
                fooHandler2:register()
                T:assert(true, 'Then no error occurs')
            end)

        end)

        T('When a second handler returning false is registered', function (T)
            local eventArg2
            Event.on('foo', function (x)
                eventArg2 = x
                return false
            end)
            assert(eventArg == nil and eventArg2 == nil)
            Event.dispatch('foo', 123)
            T:assert(eventArg == nil, 'Then the first handler does not run')
            T:assert(eventArg2 == 123, 'Then the second handler runs')
        end)

    end)

    T('When dispatchers are hooked into a table', function (T)
        local t = { bar = true }
        local eventArg
        Event.hook(t)
        Event.on('bar', function (x) eventArg = x end)
        assert(eventArg == nil)
        t.bar(123)
        T:assert(eventArg == 123, 'Then members of the table dispatch events')
    end)

    T('When dispatchers are hooked into a table of functions', function (T)
        local z = 1
        local t = { bar = function (y) z = y end }
        local eventArg
        Event.hook(t)
        Event.on('bar', function (x) eventArg = x end)
        assert(eventArg == nil)
        t.bar(123)
        T:assert(z == 123, 'Then original function runs')
        T:assert(eventArg == 123, 'Then members of the table dispatch events')
    end)

    T('When dispatchers are hooked into a table by key', function (T)
        local t = {}
        local eventArg
        Event.hook(t, { 'baz' })
        Event.on('baz', function (x) eventArg = x end)
        assert(eventArg == nil)
        t.baz(123)
        T:assert(eventArg == 123, 'Then members of the table dispatch events')
    end)

end)
