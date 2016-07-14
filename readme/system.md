# knife.system

An entity component system.

## Example usage

Require the library.

```lua
local System = require 'knife.system'
```

Define some entities. Each entity is a table of key/value pairs. Each value in an entity table is called a "component." An "entity list" is an array-like table containing entities.

```lua
local entities = {
    { name = 'sam', position = { x = 10, y = 20 }, velocity = { x = -2, y = 4 } },
    { name = 'max', position = { x = 42, y = 12 }, velocity = { x = 2, y = -4 } },
}
```

Define a system. Systems process any entity having the required components (and ignore other entities). The following system will process any entity with "position" and "velocity" components, updating the position based on the velocity. 

```lua
local updateMotion = System(
    { 'position', 'velocity' },
    function (p, v, dt)
        p.x = p.x + v.x * dt
        p.y = p.y + v.y * dt
    end)
```

Invoke a system. Pass in an entity, followed by any optional arguments.

```lua
function love.update (dt)
    for _, entity in ipairs(entities) do
        updateMotion(entity, dt)
    end
end
```

This module is only concerned with the "system" part of ECS, and doesn't
attempt to manage entity lists. However, the entities list and current index
can easily be passed into systems as optional arguments. If entities are stored
in a table, take care to reverse-iterate the table when removing entities.

```lua
local updateDeath = System(
    { 'position', 'health' },
    function (p, health, entities, i)
        if health <= 0 then
            entities[#entities + 1] = ExplosionEntity(p.x, p.y)
            table.remove(entities, i)
        end
    end)
    
function love.update (dt)
    for i = #entities, 1, -1 do
        updateDeath(entities[i], entities, i)
    end
end
```

## API

The API consists of a single function named `System`.

### System(aspects, process) -> function (entity, ...)

- `aspects`: A list of keys which must be present in entities in order to
  process them. For each "aspect", the `process` function will receive one
  argument containing the matching component.

  **pseudo-components**

  In addition to component keys, `aspects` may also contain some special
  "pseudo-component" keys. The following pseudo-components are provided:

  - `_entity`: The entity containing the components being processed.
  - `_aspects`: The aspect list passed to the System constructor.
  - `_process`: The process function passed to the System constructor.
  
  The underscore prefix is reserved for pseudo-components and should not
  be used for regular components.

  **choices**

  An aspect may contain several component keys delimited by pipe characters,
  for example:

  `name|label|title`

  These aspects will resolve to the first component found. If none of the
  components are found, the entity will not be processed.

  **sigils**

  An aspect may begin with the special characters `?`, `-`, `!`, or `=`.

  If the aspect begins with `?`, it is optional, and will not prevent the
  entity from being processed even if no matching components are found.

  If an aspect begins with `-`, the component is suppressed from the arguments
  list passed to the process function. This is useful for components that only
  help determine whether to process an entity, but the value of the component
  is not needed within the process function.

  If the aspect begins with `!`, all keys listed in the aspect must not be
  present in an entity in order to process it. These aspects have no effect
  on the arguments list.
  
  An aspect may be prefixed with `=` to indicate that it demands a return value.
  The `process` function should return one value for each aspect prefixed with
  `=` (even if the value has not changed). The returned values are used to
  update the corresponding components, allowing systems to mutate components
  with primitive values. This sigil cannot be combined with pipe-delimited
  choices.

- `process`: A function that will process components. It should take one
  parameter for each value in the `aspects` list, plus any number of additional
  parameters for optional arguments passed to the returned function following
  the entities list.

The `System` factory function returns a function representing your system.
Call this returned function as needed; for example, in your update or draw
routine. It requires an entity as the first argument, followed by any
number of optional arguments to be passed along to the `process` function.
It returns `true` if the entity was processed, otherwise it returns `nil`.

