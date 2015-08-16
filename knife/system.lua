local loadstring = _G.loadstring or _G.load
local tremove = table.remove
local tconcat = table.concat
local type = type

local underscoreByteValue = ('_'):byte()
local runningTraversals = 0
local removalList
local insertionList

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

local function updateRemovalList (list, value, entityIndex)
    if not value then
        return list
    end
    if not list then
        list = {}
    end

    local valueType = type(value)

    if valueType == 'boolean' then
        list[entityIndex] = true
        return list
    end

    if valueType == 'number' then
        list[value] = true
        return list
    end

    if valueType == 'table' then
        for i = 1, #value do
            list[value[i]] = true
        end
        return list
    end

    runningTraversals = 0
    removalList = nil
    insertionList = nil

    error 'system returned an invalid value'
end

local function updateInsertionList (list, value)
    if not value then
        return list
    end
    if not list then
        list = {}
    end

    list[#list + 1] = value

    return list
end

local function removeEntities (entities, removalList)
    if not removalList then
        return
    end

    for entityIndex = #entities, 1, -1 do
        if removalList[entityIndex] then
            tremove(entities, entityIndex)
        end
    end
end

local function createEntities (entities, insertionList)
    if not insertionList then
        return
    end
    local entitiesIndex = #entities

    for groupIndex = 1, #insertionList do
        local group = insertionList[groupIndex]
        for newEntityIndex = 1, #group do
            entitiesIndex = entitiesIndex + 1
            entities[entitiesIndex] = group[newEntityIndex]
        end
    end
end

local function traverse (entities, aspects, process, invoke, ...)

    runningTraversals = runningTraversals + 1

    for index = 1, #entities do
        local entity = entities[index]
        if not entity then
            break
        end
        if checkAspects(entity, aspects) then
            local removal, insertion = invoke(
                process, entity, entities, index, ...)

            removalList = updateRemovalList(removalList, removal, index)
            insertionList = updateInsertionList(insertionList, insertion)
        end
    end

    runningTraversals = runningTraversals - 1

    if runningTraversals == 0 then
        removeEntities(entities, removalList)
        createEntities(entities, insertionList)
        removalList = nil
        insertionList = nil
    end
end

local function generateProcessInvoker (aspects)
    local args = {}

    for index = 1, #aspects do
        local aspect = aspects[index]
        if hasInitialUnderscore(aspect) then
            args[index] = aspect
        else
            args[index] = ('_entity[%q]'):format(aspect)
        end
    end

    local source
    local template = [[
        return function (_process, _entity, _entities, _index, ...)
            return _process(%s ...)
        end
    ]]

    if args[1] then
        source = (template):format(tconcat(args, ', ') .. ', ')
    else
        source = (template):format('')
    end

    return loadstring(source)()
end

return function (aspects, process)
    local invoke = generateProcessInvoker(aspects)
    return function (entities, ...)
        return traverse(entities, aspects, process, invoke, ...)
    end
end
