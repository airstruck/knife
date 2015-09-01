T('Given Tween, a target object, and an update function', function (T)
    local Tween = require 'knife.tween'

    local group = {}

    local target = { x = 100, y = 200, z = 300 }

    local function update (dt, group)
        Tween.update(dt, group)
    end

    T('When a tween is created and update is called', function (T)
        local test = 0
        local tween = Tween(10, { [target] = { x = 200, y = 400 } })
            :group(group)
            :finish(function () test = 1 end)
            :ease(function (t, b, c, d) return c * t / d + b end)

        update(0.1, group)
        T:assert(target.x == 101 and target.y == 202,
        'Then the target values are interpolated')
        update(0.1, group)
        T:assert(target.x == 102 and target.y == 204,
        'Then the target values are interpolated x2')

        T('When the tween is stopped and update is called', function (T)
            tween:stop()
            update(0.1, group)
            T:assert(target.x == 102 and target.y == 204,
            'Then the target values are not interpolated')
        end)

        T('When the tween is updated by a large amount', function (T)
            update(10, group)
            T:assert(target.x == 200 and target.y == 400,
            'Then the target values are finalized')
            T:assert(test == 1,
            'Then the callback is invoked')
        end)

    end)

    T('When a simple tween is created and update is called', function (T)
        local tween = Tween(10, { [target] = { x = 200, y = 400 } })
        update(0.1)
        T:assert(target.x == 101 and target.y == 202,
        'Then the target values are interpolated')
    end)

end)
