local loadstring = _G.loadstring or _G.load
local tremove = table.remove
local tconcat = table.concat
local type = type

local runningTraversals = 0
local removalList
local insertionList

local function updateRemovalList (entities, value, entity)
    if not value then
        return
    end
    if not removalList then
        removalList = { byIndex = {}, byEntities = {} }
    end
    local byIndex, byEntities = removalList.byIndex, removalList.byEntities
    local list = byEntities[entities]
    if not list then
        list = {}
        byEntities[entities] = list
        byIndex[#byIndex + 1] = entities
    end

    local valueType = type(value)

    if valueType == 'boolean' then
        list[entity] = true
        return
    end

    if valueType == 'table' then
        for i = 1, #value do
            list[value[i]] = true
        end
        return
    end

    runningTraversals = 0
    removalList = nil
    insertionList = nil

    error 'system returned an invalid value'
end

local function updateInsertionList (entities, value)
    if not value then
        return
    end
    if not insertionList then
        insertionList = {}
    end

    insertionList[#insertionList + 1] = { entities, value }
end

local function removeEntities ()
    if not removalList then
        return
    end
    local byIndex, byEntities = removalList.byIndex, removalList.byEntities
    for entitiesIndex = 1, #byIndex do
        local entities = byIndex[entitiesIndex]
        local list = byEntities[entities]
        for index = #entities, 1, -1 do
            if list[entities[index]] then
                tremove(entities, index)
            end
        end
    end
    removalList = nil
end

local function createEntities ()
    if not insertionList then
        return
    end
    for itemIndex = 1, #insertionList do
        local item = insertionList[itemIndex]
        local entities, group = item[1], item[2]
        for newEntityIndex = 1, #group do
            entities[#entities + 1] = group[newEntityIndex]
        end
    end
    insertionList = nil
end

local function traverse (entities, aspects, process, invoke, ...)
    runningTraversals = runningTraversals + 1

    for index = 1, #entities do
        local entity = entities[index]
        if not entity then
            break
        end
        local old, new = invoke(process, entity, entities, index, ...)

        updateRemovalList(entities, old, entity)
        updateInsertionList(entities, new)
    end

    runningTraversals = runningTraversals - 1

    if runningTraversals == 0 then
        removeEntities()
        createEntities()
    end
end

local function hasSigil (sigil, value)
    return type(value) == 'string' and sigil:byte() == value:byte()
end

local function generateProcessInvoker (aspects)
    local args = {}
    local cond = {}
    local localIndex = 0
    local choicePattern = '([^|]+)'

    local function suppress (aspect, condition)
        cond[#cond + 1] = 'if nil'
        for option in aspect:gmatch(choicePattern) do
            cond[#cond + 1] = condition:format(option)
        end
        cond[#cond + 1] = 'then return end'
    end

    local function supply (aspect, isOptional)
        localIndex = localIndex + 1
        cond[#cond + 1] = ('local l%d = nil'):format(localIndex)
        for option in aspect:gmatch(choicePattern) do
            cond[#cond + 1] = ('or _entity[%q]'):format(option)
        end
        if not isOptional then
            cond[#cond + 1] = ('if not l%d then return end'):format(localIndex)
        end
        args[#args + 1] = ('l%d'):format(localIndex)
    end

    for index = 1, #aspects do
        local aspect = aspects[index]
        if hasSigil('_', aspect) then
            args[#args + 1] = aspect
        elseif hasSigil('!', aspect) or hasSigil('~', aspect) then
            suppress(aspect:sub(2), 'or _entity[%q]')
        elseif hasSigil('-', aspect) then
            suppress(aspect:sub(2), 'or not _entity[%q]')
        elseif hasSigil('?', aspect) then
            supply(aspect:sub(2), true)
        else
            supply(aspect, false)
        end
    end

    local source = ('%s %s return _process(%s ...) end'):format(
        'return function (_process, _entity, _entities, _index, ...)',
        tconcat(cond, ' '),
        args[1] and (tconcat(args, ', ') .. ', ') or '')

    return loadstring(source)()
end

return function (aspects, process)
    local invoke = generateProcessInvoker(aspects)
    return function (entities, ...)
        return traverse(entities, aspects, process, invoke, ...)
    end
end
