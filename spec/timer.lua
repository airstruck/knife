T('Given Timer, a target object, and an update function', function (T)
    local Timer = require 'knife.timer'

    local group = {}

    local target = { x = 100, y = 200, z = 300 }

    local function update (dt, group)
        Timer.update(dt, group)
    end

    T('When an "after" timer is created and update is called', function (T)
        local test = 0
        local timer = Timer.after(1, function (self, late) test = late end)
            :group(group)

        update(3, group)

        T:assert(test == 2,
        'Then callback fires')

        T('When group is called with no arguments', function (T)
            timer:group()

            T:assert(timer.groupField == Timer.defaultGroup,
            'Then the timer is attached the default group')

            T('When Timer.clear is called with no arguments', function (T)
                assert(#Timer.defaultGroup > 0)

                Timer.clear()

                T:assert(#Timer.defaultGroup == 0,
                'Then the default group is cleared')
            end)

        end)

    end)

    T('When an "every" timer is created and update is called', function (T)
        local test = 0
        local test2
        local timer = Timer.every(1, function () test = test + 1 end)
            :group(group)
            :limit(4)
            :finish(function () test2 = 1 end)

        update(3, group)
        update(1, group)
        update(1, group)

        T:assert(test == 4,
        'Then callback fires')
    end)

    T('When a "prior" timer is created and update is called', function (T)
        local test = 0
        local test2
        local timer = Timer.prior(3, function (self, dt) test = test + dt end)
            :group(group)
            :finish(function () test2 = 1 end)

        update(1, group)
        update(1, group)
        update(1, group)
        update(1, group)
        update(1, group)
        update(1, group)

        T:assert(test == 3,
        'Then callback fires')
        T:assert(test2 == 1,
        'Then finalizer fires')

    end)

    T('When a tween is created and update is called', function (T)
        local test = 0
        local tween = Timer.tween(10, { [target] = { x = 200, y = 400 } })
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
            tween:remove()
            update(0.1, group)
            T:assert(target.x == 102 and target.y == 204,
            'Then the target values are not interpolated')

            T('When the tween is registered and update is called', function (T)
                tween:register()
                update(0.1, group)
                T:assert(target.x == 103 and target.y == 206,
                'Then the target values are interpolated')
            end)
            
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
        Timer.tween(10, { [target] = { x = 200, y = 400 } })
        update(0.1)
        T:assert(target.x == 101 and target.y == 202,
        'Then the target values are interpolated')
    end)

end)
