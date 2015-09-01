local Tween = {}

local function remove (array, index)
    array[index] = array[#array]
    array[index].index = index
    array[#array] = nil
end

local function append (array, item)
    local index = #array + 1
    item.index = index
    array[index] = item
end

local function define (definition)
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

local function update (self, dt)
    local elapsed = self.elapsed + dt
    local plan = self.plan
    local duration = self.duration
    
    self.elapsed = elapsed
        
    if elapsed >= duration then
        for index = 1, #plan do
            local task = plan[index]
            
            task.target[task.key] = task.final
        end
        if self.callback then
            self:callback(elapsed - duration)
        end
        self:stop()
        return
    end
    
    local ease = self.easingFunction
    
    for index = 1, #plan do
        local task = plan[index]
        local target, key = task.target, task.key
        local initial, change = task.initial, task.change
        
        target[key] = ease(elapsed, initial, change, duration)
    end
    
end

local function ease (self, easingFunction)
    self.easingFunction = easingFunction
    
    return self
end

local function finish (self, callback)
    self.callback = callback
    
    return self
end

local function group (self, group)
    remove(self.ownerGroup, self.index)
    append(group, self)
    self.ownerGroup = group
    
    return self
end

local function stop (self)
    remove(self.ownerGroup, self.index)
    
    return self
end

local defaultGroup = {}

local function construct (_, duration, definition)
    local instance = {
        duration = duration,
        plan = define(definition),
        elapsed = 0,
        easingFunction = easeLinear,
        ownerGroup = defaultGroup,
        update = update,
        ease = ease,
        finish = finish,
        group = group,
        stop = stop,
    }
    
    append(defaultGroup, instance)
    
    return instance
end

function Tween.update (dt, group)
    if not group then
        group = defaultGroup
    end
    for index = #group, 1, -1 do
        group[index]:update(dt)
    end
end

return setmetatable(Tween, { __call = construct })

