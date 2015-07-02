T('memoize', 
function (T)
    
  local memoize = require 'knife.memoize'

  local counter = 0

  local function count(...)
    counter = counter + 1
    return counter
  end

  local memoized_count = memoize(count)

  local function switch(x,y)
    counter = counter + 1
    return y,x
  end

  local memoized_switch = memoize(switch)

  local countable = setmetatable({}, {__call = count})
  local memoized_countable = memoize(countable)

  local function count2(...)
    counter = counter + 1
    return counter
  end

  T("should accept ony non-callable parameters, and error otherwise", 
  function (T)
    T:error(function() memoize() end)
    T:error(function() memoize('foo') end)
    T:error(function() memoize(1) end)
    T:error(function() memoize({}) end)
    memoize(print)
    memoize(countable)
  end)
  T("should work with 0 parameters", 
  function (T)
    memoized_count()
    T:assert(memoized_count() == 1)
    T:assert(counter == 1)
  end)

  T("should work with one parameter", 
  function (T)
    memoized_count('foo')
    T:assert(memoized_count('foo') == 1)
    T:assert(memoized_count('bar') == 2)
    T:assert(memoized_count('foo') == 1)
    T:assert(memoized_count('bar') == 2)
    T:assert(counter == 2)
  end)

  T("should work with two parameters", 
  function (T)
    memoized_count('foo', 'bar')
    T:assert(memoized_count('foo', 'bar') == 1, '1')
    T:assert(memoized_count('foo', 'baz') == 2, '2')
    T:assert(memoized_count('foo', 'bar') == 1, '3')
    T:assert(memoized_count('foo', 'baz') == 2, '4')
    T:assert(counter == 2)
  end)

  T("should work with tables & functions", 
  function (T)
    local t1 = {}
    local t2 = {}
    T:assert(memoized_count(print, t1) == 1)
    T:assert(memoized_count(print, t2) == 2)
    T:assert(memoized_count(print, t1) == 1)
    T:assert(memoized_count(print, t2) == 2)
    T:assert(counter == 2)
  end)

  T("should return multiple values when needed", 
  function (T)
    local x,y = memoized_switch(100, 200)
    T:assert(x == 200)
    T:assert(y == 100)
    T:assert(counter == 1)
    x,y = memoized_switch(400, 500)
    T:assert(x == 500)
    T:assert(y == 400)
    T:assert(counter == 2)
    x,y = memoized_switch(100, 200)
    T:assert(x == 200)
    T:assert(y == 100)
    T:assert(counter == 2)
    x,y = memoized_switch(400, 500)
    T:assert(x == 500)
    T:assert(y == 400)
    T:assert(counter == 2)
  end)

  T("should clean cache when called twice", 
  function (T)
    memoized_count('reset')
    T:assert(memoized_count('reset') == 1)
    memoize(count)
    T:assert(memoized_count('reset') == 2)
  end)

  T( 'callable tables', 
  function (T)
    
    T("Unchanged callable tables should work just like functions", 
    function (T)
      memoized_countable()
      T:assert(memoized_countable() == 1)
      T:assert(counter == 1)
      memoized_countable('foo')
      T:assert(memoized_countable('foo') == 2)
      T:assert(counter == 2)
    end)

    T("When callable table's __call metamethod is changed, the cache is reset", 
    function (T)
      memoized_countable('bar')
      T:assert(memoized_countable('bar') == 1)
      local mt = getmetatable(countable)
      mt.__call = count2
      memoized_countable('bar')
      T:assert(memoized_countable('bar') == 2)
      T:assert(memoized_countable('bar') == 2)
    end)

    T("An error is thrown if a memoized callable table loses its __call", 
    function (T)
      local mt = getmetatable(countable)
      mt.__call = nil
      T:error(function() memoized_countable() end)
    end)
  end)
  
  T("airstruck", 
  function (T)
  
      T("handles nil arguments", 
      function (T)
  
        local function cat(a, b, c)
          return tostring(a) .. tostring(b) .. tostring(c)
        end

        local memoized_cat = memoize(cat)
        
        T:assert(memoized_cat('a', 'b', 'c') == 'abc', '1')
        T:assert(memoized_cat('a', 'b', 'c') == 'abc', '2')
        
        T:assert(memoized_cat('va', nil, 'la') == 'vanilla', '3')
        T:assert(memoized_cat('va', nil, 'la') == 'vanilla', '4')
        
        T:assert(memoized_cat('va', 'la') == 'valanil', '5')
        T:assert(memoized_cat('va', 'la') == 'valanil', '6')
        
        T:assert(memoized_cat('va') == 'vanilnil', '7')
        T:assert(memoized_cat('va') == 'vanilnil', '8')
        
      end)
      
      T("handles nil results", 
      function (T)
      
        local function passthrough (a, b, c)
          return a, b, c
        end

        local memoized_passthrough = memoize(passthrough)
      
        local a, b, c = memoized_passthrough('a', 'b', 'c')
        T:assert(a == 'a') T:assert(b == 'b') T:assert(c == 'c')
        
        a, b, c = memoized_passthrough('a', 'b', 'c')
        T:assert(a == 'a') T:assert(b == 'b') T:assert(c == 'c')
        
        x, y, z = memoized_passthrough('x', nil, 'z')
        T:assert(x == 'x') T:assert(y == nil) T:assert(z == 'z')
        
        x, y, z = memoized_passthrough('x', nil, 'z')
        T:assert(x == 'x') T:assert(y == nil) T:assert(z == 'z')
        
      end)
      
  end)

end)

