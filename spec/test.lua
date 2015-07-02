T('Given an empty table', 
function (T)
  local t = {}
  T('When an item is inserted into a table', 
  function (T)
    assert(#t == 0)
    table.insert(t, 111)
    T:assert(#t == 1, 'Then the size of the table is 1')
    T:assert(t[1] == 111, 'Then the item is stored in index 1')
    
    T('When the index is set to nil', 
    function (T)
      assert(#t == 1)
      t[1] = nil
      T:assert(#t == 0, 'Then the size of the table is 0')
        pcall(function ()
            T:error(function () end, 'THIS TEST INTENTIONALLY FAILS')
        end)
    end)
    
    T('When another item is inserted', 
    function (T)
      assert(#t == 1)
      table.insert(t, 222)
      T:assert(#t == 2, 'Then the size of the table is 2')
      T:assert(t[2] == 222, 'Then the second item is stored in index 2')

      T('When the first item is removed with table.remove', 
      function (T)
        assert(#t == 2)
        table.remove(t, 1)
        T:assert(#t == 1, 'Then the size of the table is 1')
        T:assert(t[1] == 222, 'Then the second item has moved to index 1')
      end)
      
      T('When the first item is set to nil', 
      function (T)
        assert(#t == 2)
        t[1] = nil
        T:assert(#t == 2, 'Then the size of the table is 2')
        T:assert(t[2] == 222, 'Then the second item remains in index 2')
        pcall(function () 
            T:assert(false, 'THIS TEST INTENTIONALLY FAILS') 
        end)
      end)
    end)
    
  end)
end)

T('Given a value of two', function (T)
  local value = 2
  T('When the value is increased by five', function (T)
    -- here, value is 2
    value = value + 5
    local foo = 10
    T:assert(value == 7 and foo == 10, 'Then the value equals seven')
  end)
  T('When the value is decreased by five', function (T)
    -- value is 2 again; this test is isolated from the "increased by five" test
    value = value - 5
    T:assert(value == -3, 'Then the value equals negative three')
  end)
end)

T('Given a value of two', function (T)
  local value = 2
  T:assert(value == 2, 'Then the value equals two')
end)
