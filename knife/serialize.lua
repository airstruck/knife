local tinsert, tconcat, infinity = table.insert, table.concat, math.huge

return function (value)
    local intro, outro, ready, known = {}, {}, {}, {}
    local knownCount = 0
    local writer = {}

    -- get writer delegate for this value's type
    local function getWriter (value)
        return writer[type(value)]
    end

    -- check if a value has a representation yet
    local function isReady (value)
        return type(value) ~= 'table' or ready[value]
    end

    -- serialize tables
    function writer.table (value)
        if known[value] then
            return known[value]
        end

        knownCount = knownCount + 1
        local variable = ('v%i'):format(knownCount)
        known[value] = variable

        local parts = {}
        for k, v in pairs(value) do
            local writeKey, writeValue = getWriter(k), getWriter(v)
            if writeKey and writeValue then
                local key, value = writeKey(k), writeValue(v)
                if isReady(k) and isReady(v) then
                    tinsert(parts, ('[%s]=%s'):format(key, value))
                else
                    tinsert(outro, ('%s[%s]=%s'):format(variable, key, value))
                end
            end
        end

        local fields = tconcat(parts, ',')
        tinsert(intro, ('local %s={%s}'):format(variable, fields))
        ready[value] = true

        return variable
    end

    -- preserve sign bit on NaN, since Lua prints "nan" or "-nan"
    local function writeNan (n)
        return tostring(n) == tostring(0/0) and '0/0' or '-(0/0)'
    end

    -- serialize numbers
    function writer.number (value)
        return value == infinity and '1/0'
            or value == -infinity and '-1/0'
            or value ~= value and writeNan(value)
            or ('%.17G'):format(value)
    end

    -- serialize strings
    function writer.string (value)
        return ('%q'):format(value)
    end

    -- serialize booleans
    writer.boolean = tostring

    -- concatenate array, joined by and terminated with line break
    local function lines (t)
        return #t == 0 and '' or tconcat(t, '\n') .. '\n'
    end

    -- generate serialized result
    local write = getWriter(value)
    local result = write and write(value) or 'nil'
    return lines(intro) .. lines(outro) .. 'return ' .. result
end
