local Timer = {}

-- group management

local function detach (group, item)
    local index = item.index

    group[index] = group[#group]
    group[index].index = index
    group[#group] = nil
    item.groupField = nil
end

local function attach (group, item)
    if item.groupField then
        detach (item.groupField, item)
    end

    local index = #group + 1

    item.index = index
    group[index] = item
    item.groupField = group
    item.lastGroup = group
end

-- instance update methods

local function updateContinuous (self, dt)
    local cutoff = self.cutoff
    local elapsed = self.elapsed + dt

    if self:callback(dt) == false or elapsed >= cutoff then
        if self.finishField then
            self:finishField(elapsed - cutoff)
        end
        self:remove()
    end

    self.elapsed = elapsed

    return
end

local function updateIntermittent (self, dt)
    local duration = self.delay or self.interval
    local elapsed = self.elapsed + dt

    while elapsed >= duration do
        elapsed = elapsed - duration
        if self.limitField then
            self.limitField = self.limitField - 1
        end
        if self:callback(elapsed) == false
        or self.delay or self.limitField == 0 then
            if self.finishField then
                self:finishField(elapsed)
            end
            self:remove()
            return
        end
    end

    self.elapsed = elapsed
end

local function updateTween (self, dt)
    local elapsed = self.elapsed + dt
    local plan = self.plan
    local duration = self.duration

    self.elapsed = elapsed

    if elapsed >= duration then
        for index = 1, #plan do
            local task = plan[index]

            task.target[task.key] = task.final
        end
        if self.finishField then
            self:finishField(elapsed - duration)
        end
        self:remove()
        return
    end

    local ease = self.easeField

    for index = 1, #plan do
        local task = plan[index]
        local target, key = task.target, task.key
        local initial, change = task.initial, task.change

        target[key] = ease(elapsed, initial, change, duration)
    end

end

-- shared instance methods

local defaultGroup = {}

local function group (self, group)
    if not group then
        group = defaultGroup
    end

    attach(group, self)

    return self
end

local function remove (self)
    if self.groupField then
        detach(self.groupField, self)
    end

    return self
end

local function register (self)
    attach(self.lastGroup, self)

    return self
end

local function limit (self, limitField)
    self.limitField = limitField

    return self
end

local function finish (self, finishField)
    self.finishField = finishField

    return self
end

local function ease (self, easeField)
    self.easeField = easeField

    return self
end

-- tweening helper functions

local function planTween (definition)
    local plan = {}

    for target, values in pairs(definition) do
        for key, final in pairs(values) do
            local initial = target[key]

            plan[#plan + 1] = {
                target = target,
                key = key,
                initial = initial,
                final = final,
                change = final - initial,
            }
        end
    end

    return plan
end

local function easeLinear (elapsed, initial, change, duration)
    return change * elapsed / duration + initial
end

-- instance initializer

local function initialize (timer)
    timer.elapsed = 0
    timer.group = group
    timer.remove = remove
    timer.register = register

    attach(defaultGroup, timer)

    return timer
end

-- static api

function Timer.after (delay, callback)
    return initialize {
        delay = delay,
        callback = callback,
        update = updateIntermittent,
    }
end

function Timer.every (interval, callback)
    return initialize {
        interval = interval,
        callback = callback,
        update = updateIntermittent,
        limit = limit,
        finish = finish,
     }
end

function Timer.prior (cutoff, callback)
    return initialize {
        cutoff = cutoff,
        callback = callback,
        update = updateContinuous,
        finish = finish,
    }
end

function Timer.tween (duration, definition)
    return initialize {
        duration = duration,
        plan = planTween(definition),
        update = updateTween,
        easeField = easeLinear,
        ease = ease,
        finish = finish,
    }
end

function Timer.update (dt, group)
    if not group then
        group = defaultGroup
    end
    for index = #group, 1, -1 do
        group[index]:update(dt)
    end
end

function Timer.clear (group)
    if not group then
        group = defaultGroup
    end
    for i = 1, #group do
        group[i] = nil
    end
end

Timer.defaultGroup = defaultGroup

return Timer
