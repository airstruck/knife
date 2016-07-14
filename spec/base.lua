local function checkSubSuper (T, Sub, Super)
  T:assert(getmetatable(Sub).__index == Super,
  'Then the super is the index for the sub')
  T:assert(Sub ~= Super,
  'Then the super is not identical to the sub')
end

local function checkNotCallable (T, instance)
  T:error(function () instance() end,
  'Then the instance is not callable')
end

local function checkConstruct (T, Class)
  T('When instantiated with the default constructor',
  function (T)
    Class.constructor = nil
    local c = Class()
    checkSubSuper(T, c, Class)
    checkNotCallable (T, c)
  end)
  T('When instantiated with a custom constructor',
  function (T)
    function Class:constructor (x) self.x = x; return x, 45 end
    local c, x, y = Class(123)
    T:assert(c.x == 123,
    'Then the constructor is applied to the instance')
    T:assert(x == 123 and y == 45,
    'Then return values from the constructor follow the instance')
    checkSubSuper(T, c, Class)
    checkNotCallable (T, c)
  end)
end

local function checkExtend (T, Class)
  T('When a class is extended',
  function (T)
    local Sub = Class:extend()
    checkSubSuper(T, Sub, Class)
    checkConstruct(T, Sub)
  end)
end

T('Given a base class',
function (T)
  local Base = require 'knife.base'
  T('When the base class is extended with no arguments',
  function (T)
    local Thing = Base:extend()
    checkSubSuper(T, Thing, Base)
    checkConstruct(T, Thing)
    checkExtend (T, Thing)
  end)
  T('When the base class is extended with a table argument',
  function (T)
    local t = { x = 1 }
    local Thing = Base:extend(t)
    T:assert(Thing == t,
    'Then the new class is identical to the table')
    checkSubSuper(T, Thing, Base)
    checkConstruct(T, Thing)
    checkExtend (T, Thing)
  end)
end)
