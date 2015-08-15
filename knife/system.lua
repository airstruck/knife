local System = {}

local function removeEntities (entities, indicesToRemove)
    local indicesToRemoveIndex = #indicesToRemove

    for entityIndex = #entities, 1, -1 do
        if indicesToRemove[indicesToRemoveIndex] == entityIndex then
            indicesToRemoveIndex = indicesToRemoveIndex - 1
            table.remove(entities, entityIndex)
        end
    end
end

local function createEntities (entities, newEntityGroups)
    local entitiesIndex = #entities

    for groupIndex = 1, #newEntityGroups do
        local group = newEntityGroups[groupIndex]
        for newEntityIndex = 1, #group do
            entitiesIndex = entitiesIndex + 1
            entities[entitiesIndex] = group[newEntityIndex]
        end
    end
end

local underscoreByteValue = ('_'):byte()

local function hasInitialUnderscore (value)
    return type(value) == 'string' and value:byte() == underscoreByteValue
end

local function checkAspects (entity, aspects)
    for index = 1, #aspects do
        local aspect = aspects[index]
        if entity[aspect] == nil and not hasInitialUnderscore(aspect) then
            return false
        end
    end
    return true
end

local function traverse (entities, aspects, process, invoke, ...)
    local indicesToRemove
    local newEntityGroups

    for index = 1, #entities do
        local entity = entities[index]

        if checkAspects(entity, aspects) then

            local shouldRemove, newEnts = invoke(
                process, entity, entities, index, ...)

            if shouldRemove then
                if not indicesToRemove then
                    indicesToRemove = {}
                end
                indicesToRemove[#indicesToRemove + 1] = index
            end

            if newEnts then
                if not newEntityGroups then
                    newEntityGroups = {}
                end
                newEntityGroups[#newEntityGroups + 1] = newEnts
            end

        end

    end

    if indicesToRemove then
        removeEntities(entities, indicesToRemove)
    end

    if newEntityGroups then
        createEntities(entities, newEntityGroups)
    end
end

local function generateProcessInvoker (aspects)
    local args = {}

    for _, aspect in ipairs(aspects) do
        if hasInitialUnderscore(aspect) then
            args[#args + 1] = aspect
        else
            args[#args + 1] = ('_entity[%q]'):format(aspect)
        end
    end
    local template = [[
        return function (_process, _entity, _entities, _index, ...)
            return _process(%s, ...)
        end
    ]]
    local source = (template):format(table.concat(args, ', '))

    return loadstring(source)()
end

function System.create (aspects, process)
    local invoke = generateProcessInvoker(aspects)
    return function (entities, ...)
        return traverse(entities, aspects, process, invoke, ...)
    end
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

return setmetatable(System, { __call = function (System, ...)
    return System.create(...)
end })
