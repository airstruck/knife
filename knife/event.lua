-- Event module
local Event = {}

-- Event handler registry
Event.handlers = {}

-- Remove an event handler from the registry
local function removeHandler (self)
    if self.prevHandler then
        self.prevHandler.nextHandler = self.nextHandler
    end
    if self.nextHandler then
        self.nextHandler.prevHandler = self.prevHandler
    end
    if Event.handlers[self.name] == self then
        Event.handlers[self.name] = self.nextHandler
    end
    self.prevHandler = nil
    self.nextHandler = nil
end

-- Create an event handler
local function Handler (name, callback)
    return { 
        name = name, 
        callback = callback, 
        remove = removeHandler
    }
end

-- Insert an event handler into the registry
local function register (handler)
    handler.nextHandler = Event.handlers[handler.name]
    if handler.nextHandler then
        handler.nextHandler.prevHandler = handler
    end
    Event.handlers[handler.name] = handler
    
    return handler
end

-- Create and register a new event handler
function Event.on (name, callback)
    return register(Handler(name, callback))
end

-- Dispatch an event
function Event.dispatch (name, ...)
    local handler = Event.handlers[name]
    
    while handler do
        if handler.callback(...) == false then 
            return handler
        end
        handler = handler.nextHandler
    end
end

-- Inject a dispatcher into a table.
local function injectDispatcher (t, key)
    t[key] = function (...)
        return Event.dispatch(key, ...)
    end
end

-- Inject dispatchers into a table. Examples:
-- Event.injectDispatchers(love.handlers)
-- Event.injectDispatchers(love, { 'load', 'update', 'draw' })
function Event.injectDispatchers (t, keys)
    if keys then
        for _, key in ipairs(keys) do
            injectDispatcher(t, key)
        end
    else
        for key in pairs(t) do 
            injectDispatcher(t, key)
        end
    end
end

return Event

