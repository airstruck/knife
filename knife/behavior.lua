-- behavior.lua -- a state manager

-- internal/external api

local function getCurrentFrame (behavior)
    return behavior.states[behavior.state][behavior.index]
end

local function advanceFrame (behavior)
    local nextState = behavior.frame.after
    local nextIndex = behavior.index + 1
    local maxIndex = #behavior.states[behavior.state]

    if nextState then
        behavior.state = nextState
        nextIndex = 1
    elseif nextIndex > maxIndex then
        nextIndex = 1
    end

    behavior.index = nextIndex
    behavior.frame = behavior:getCurrentFrame()
end

local function performAction (behavior)
    local act = behavior.frame.action

    if act then
        act(behavior, behavior.subject)
    end
end

-- external api

local function update (behavior, dt)
    behavior.elapsed = behavior.elapsed + dt

    while behavior.elapsed >= behavior.frame.duration do
        behavior.elapsed = behavior.elapsed - behavior.frame.duration
        behavior:advanceFrame()
        behavior:performAction()
    end

    return behavior
end

local function setState (behavior, state, index)
    behavior.state = state
    behavior.index = index or 1
    behavior.elapsed = 0
    behavior.frame = behavior:getCurrentFrame()
    behavior:performAction()
    return behavior
end

-- behavior factory

return function (states, subject)
    local behavior = {
        states = states,
        subject = subject,
        elapsed = 0,
        state = 'default',
        index = 1,
        -- internal api
        getCurrentFrame = getCurrentFrame,
        advanceFrame = advanceFrame,
        performAction = performAction,
        -- external api
        update = update,
        setState = setState
    }

    behavior.frame = behavior:getCurrentFrame()
    behavior:performAction()

    return behavior
end
