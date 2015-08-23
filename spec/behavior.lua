T('Given some states', function (T)

    local Behavior = require 'knife.behavior'

    local thought = false

    local function think (behavior, subject)
        thought = true
    end

    local states = {
        default = {
            { sprite = 'human.idle.a', duration = 1, after = 'idle' },
        },
        idle = {
            { sprite = 'human.idle.a', duration = 3 },
            { sprite = 'human.idle.b', duration = 1 },
            { sprite = 'human.idle.a', duration = 2 },
            { sprite = 'human.idle.c', duration = 1, action = think },
        },
        walk = {
            { sprite = 'human.run.a', duration = 0.2 },
            { sprite = 'human.run.b', duration = 0.2 },
            { sprite = 'human.run.c', duration = 0.2 },
            { sprite = 'human.run.b', duration = 0.2 },
        },
    }

    T('When a behavior is created', function (T)
        local subject = {}
        local behavior = Behavior(states, subject)
        local frame = behavior.frame
        T:assert(frame,
        'Then the behavior has a current frame')

        T('When the behavior is updated by a small dt', function (T)
            behavior:update(0.5)
            T:assert(behavior.frame == frame,
            'Then the behavior has the same frame')
        end)

        T('When the behavior is updated by a larger dt', function (T)
            behavior:update(2)
            T:assert(behavior.frame ~= frame,
            'Then the behavior has a new frame')
        end)

        T('When the behavior encounters an action', function (T)
            assert(thought == false)
            behavior:update(20)
            T:assert(thought == true,
            'Then the action executes')
        end)

        T('When the behavior is set to a state', function (T)
            behavior:setState('walk', 2)
            T:assert(behavior.frame == states.walk[2],
            'Then the frame is set accordingly')
        end)

    end)

end)
