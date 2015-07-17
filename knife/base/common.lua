if _G.common_class == false then return end

local Base = require 'knife.base'

_G.common = {
    class = function (name, class, superclass)
        local c = Base.extend(superclass or Base, class)
        c.constructor = class.init
        return c
    end,
    instance = function (class, ...)
        return (class(...))
    end
}

