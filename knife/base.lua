return {
    extend = function (self, subtype)
        return setmetatable(subtype or {}, {
            __index = self,
            __call = function (self, ...)
                local instance = setmetatable({}, { __index = self })
                return instance, instance:constructor(...)
            end
        })
    end,
    constructor = function () end,
}
