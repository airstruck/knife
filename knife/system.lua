local System = {}

local cache = setmetatable({}, { __mode = 'k' })

System.forward = ipairs

function System.reverse (list)
    local function reverse (list, index)
        if index <= 1 then return end
        index = index - 1
        return index, list[index]
    end
    
    return reverse, list, #list + 1
end

local function extractComponent (context, entity, aspect) 
    return context[aspect] or entity[aspect]
end

local function extractComponents (context, entity, aspects) 
    local components = {}
    
    for index, aspect in ipairs(aspects) do
        local component = extractComponent(context, entity, aspect) 
        if not component then return end
        components[index] = component
    end
    
    return components
end

local function extractComponentsList (entities, aspects, iterator) 
    local cached = cache[entities]
    
    if not iterator then
        iterator = System.forward
    end
    
    if cached and cached[aspects] and cached[aspects][iterator] then 
        return cached[aspects][iterator]
    end
    
    local list = {}
    local context = { _entities = entities }
    
    for index, entity in iterator(entities) do
        context._index = index
        context._entity = entity
        list[#list + 1] = extractComponents(context, entity, aspects)
    end
    
    if cached then
        if cached[aspects] then
            cached[aspects][iterator] = list
        else
            cached[aspects] = setmetatable({ [iterator] = list },
                { __mode = 'k' })
        end 
    end
    
    return list
end

local function unpackArgs (list, index, ...)
    if index > #list then
        return ... 
    end
    
    return list[index], unpackArgs(list, index + 1, ...)
end

local function traverse (entities, aspects, iterator, process, ...)
    local componentsList = extractComponentsList(entities, aspects, iterator)
    
    for index, components in ipairs(componentsList) do
        process(unpackArgs(components, 1, ...))
    end
    
    return context
end

function System.each (entities, aspects, iterator, process, ...) 
    if process then
        return traverse(entities, aspects, iterator, process, ...) 
    else 
        return coroutine.wrap(function ()
            traverse(entities, aspects, iterator, coroutine.yield)
        end)
    end
end

function System.create (aspects, process, iterator)
    return function (entities, ...)
        return traverse(entities, aspects, iterator, process, ...)
    end
end

function System.cache (entities)
    cache[entities] = setmetatable({}, { __mode = 'k' })
end

function System.invalidate (entities)
    if cache[entities] then
        System.cache (entities)
    end
end

function System.uncache (entities)
    cache[entities] = nil
end

local entityMaxId = 0

System.entities = setmetatable({}, { __mode = 'v' })

System.ids = setmetatable({}, { 
    __mode = 'k', 
    __index = function(self, entity) 
        entityMaxId = entityMaxId + 1
        self[entity] = entityMaxId
        System.entities[entityMaxId] = entity
        return entityMaxId
    end
})

return System

