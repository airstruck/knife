T('Given some systems and some entities',
function (T)
    local System = require 'knife.system'

    local e1 = {
        position = { x = 10, y = 20 },
    }
    local e2 = {
        position = { x = 30, y = 40 },
        velocity = { x = 1, y = 2 }
    }

    local updatePosition = System(
    { 'position', 'velocity' },
    function (pos, vel)
        pos.x = pos.x + vel.x
        pos.y = pos.y + vel.y
    end)

    local entities = { e1, e2 }

    T('When a system is invoked',
    function (T)
        updatePosition(e2)
        T:assert(entities[2].position.y == 42,
        'Then the components of the entities are updated')
    end)

    T('When a system with an empty aspects list is invoked',
    function (T)
        local counter = 0

        local noAspects = System({}, function ()
            counter = counter + 1
        end)

        noAspects(e1)
        noAspects(e2)
        T:assert(counter == 2,
        'Then all entities are processed')
    end)

    T('When a system references a pseudo-component',
    function (T)
        local results = {}
        local pseudo = System(
        { '_entity' },
        function (entity)
            results[#results + 1] = entity
        end)
        pseudo(e1)
        pseudo(e2)
        T:assert(results[1] == e1 and results[2] == e2,
        'Then the pseudo-component is available to the process')
    end)

    T('When an aspect has choices',
    function (T)

        local result

        local s = System(
        { 'position|velocity', 'position', 'velocity' },
        function (pv, p, v)
            result = pv == p
        end)
        s(e1)
        s(e2)
        T:assert(result, 'Then first available is chosen')

        local s = System(
        { 'velocity|position', 'position', 'velocity' },
        function (pv, p, v)
            result = pv == v
        end)
        s(e1)
        s(e2)
        T:assert(result, 'Then first available is chosen x2')

    end)

    T('When an aspect has reject sigil',
    function (T)

        local result

        local s = System(
        { '!velocity', 'position' },
        function (p)
            result = p.x
        end)
        s(e1)
        s(e2)
        T:assert(result == 10, 'Then matching entities are not processed')

    end)

    T('When an aspect has mute sigil',
    function (T)

        local result

        local s = System(
            { 'position', '-velocity', '_entity' },
            function (p, e)
                result = { p, e }
            end)
        s(e1)
        s(e2)
        T:assert(result[1] == e2.position and result[2] == e2,
        'Then it is suppressed from the args list')

    end)

    T('When an aspect has option sigil',
    function (T)

        local result = {}

        local s = System(
            { 'position', '?velocity', '_entity' },
            function (p, v, e)
                result[#result + 1] = { p, v, e }
            end)
        s(e1)
        s(e2)

        T:assert(result[1][1] == e1.position
            and result[1][2] == nil
            and result[1][3] == e1
            and result[2][1] == e2.position
            and result[2][2] == e2.velocity
            and result[2][3] == e2,
            'Then it is optional')

    end)
    
    T('When an aspect has return sigil',
    function (T)

        local result

        local s = System(
            { 'position', '=velocity', '_entity' },
            function (p, v, e)
                return { x = 2, y = 1 }
            end)
        s(e1)
        s(e2)
        T:assert(e2.velocity.x == 2,
        'Then it is set from return value')

    end)
end)
