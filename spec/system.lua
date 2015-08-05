T('Given a system and some entities',
function (T)
  local System = require 'knife.system'
  
  local posvel = { 'position', 'velocity' }
  
  local updatePosition = System.create(
    posvel,
    function (pos, vel)
      pos.x = pos.x + vel.x
      pos.y = pos.y + vel.y
    end
  )
  
  local updateBoundary = System(
    posvel,
    function (pos, vel)
      if pos.y > 40 then
        vel.y = vel.y * -1
      end
    end, System.reverse
  )
  
  local entities = {
    {
      position = { x = 10, y = 20 }, 
      velocity = { x = 2, y = 1 }
    },
    {
      position = { x = 30, y = 40 }, 
      velocity = { x = 1, y = 2 }
    }
  }
    
  T('When a system is invoked',
  function (T)
    updatePosition(entities)
    T:assert(entities[1].position.x == 12 and entities[2].position.y == 42,
    'Then the components of the entities are updated')
  end)
  
  T('When the entities list is cached',
  function (T)
    System.cache(entities)
    
    T('When a system is invoked',
    function (T)
      updatePosition(entities)
      T:assert(entities[1].position.x == 12 and entities[2].position.y == 42,
      'Then the components of the entities are updated')
      
      T('When the other system is invoked',
      function (T)
        updateBoundary(entities)
        T:assert(entities[2].velocity.y == -2,
        'Then the components of the entities are updated')
      end)
      
      T('When a system is invoked a second time',
      function (T)
        updatePosition(entities)
        T:assert(entities[1].position.x == 14 and entities[2].position.y == 44,
        'Then the components of the entities are updated a second time')
        
        T('When the cache is invalidated and a system is invoked a third time',
        function (T)
          System.invalidate(entities)
          updatePosition(entities)
          T:assert(entities[1].position.x == 16 and entities[2].position.y == 46,
          'Then the components of the entities are updated a third time')
        end)
        
        T('When the cache is removed and a system is invoked a third time',
        function (T)
          System.uncache(entities)
          updatePosition(entities)
          T:assert(entities[1].position.x == 16 and entities[2].position.y == 46,
          'Then the components of the entities are updated a third time')
        end)
        
      end)
      
    end)
    
  end)
  
  T('When System.each is invoked as an iterator',
  function (T)
    for pos, vel in System.each(entities, posvel) do
      pos.x = pos.x + vel.x
      pos.y = pos.y + vel.y
    end
    T:assert(entities[1].position.x == 12 and entities[2].position.y == 42,
    'Then the components of the entities are updated')
  end)
  
  T('When System.each is invoked with a callback',
  function (T)
    System.each(entities, posvel, System.forward, function (pos, vel)
      pos.x = pos.x + vel.x
      pos.y = pos.y + vel.y
    end)
    T:assert(entities[1].position.x == 12 and entities[2].position.y == 42,
    'Then the components of the entities are updated')
  end)
  
  T('When getting an id for an entity',
  function (T)
    local id1 = System.ids[entities[1]]
    T:assert(id1,
    'Then the id is returned')
    
    T('When getting an id for the same entity',
    function (T)
      local id2 = System.ids[entities[1]]
      T:assert(id1 == id2,
      'Then the same id is returned')
    end)
    
    T('When getting the entity from the id',
    function (T)
      local e = System.entities[id1]
      T:assert(e == entities[1],
      'Then the same entity is returned')
    end)
  
  end)
  
end)
