T('Given a system and some entities',
function (T)
  local System = require 'knife.system'


    local e1 = {
        position = { x = 10, y = 20 },
    }
    local e2 = {
        position = { x = 30, y = 40 },
        velocity = { x = 1, y = 2 }
    }
    local e3 = {
        position = { x = 1, y = 2 },
        velocity = { x = 2, y = 1 }
    }

  local posvel = { 'position', 'velocity' }

  local updatePosition = System(
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
        return true
      end
    end
  )

  local addStuff = System(
    posvel,
    function (pos, vel)
      return false, { e3 }
    end
  )

    local manualRemove = System(
      { 'position', '_index', '_entities' },
      function (pos, i, e)
        if i == 1 then
            table.remove(e, i)
        end
      end
    )


    local entities = { e1, e2 }

    T('When a system is invoked',
    function (T)
        updatePosition(entities)
        T:assert(entities[2].position.y == 42,
        'Then the components of the entities are updated')
    end)

    T('When a process returns a truthy value',
    function (T)
        assert(#entities == 2)
        updatePosition(entities)
        updateBoundary(entities)
        T:assert(#entities == 1 and entities[1] == e1,
        'Then the current entity is removed')
    end)

    T('When a process manually removes an entity',
    function (T)
        assert(#entities == 2)
        manualRemove(entities)
        T:assert(#entities == 1 and entities[1] == e2,
        'Then the entity is removed')
    end)

    T('When a process returns new entities',
    function (T)
        assert(#entities == 2)
        addStuff(entities)
        T:assert(entities[3] == e3,
        'Then the new entities are added')
    end)

end)
