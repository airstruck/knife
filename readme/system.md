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

Define a system. Systems iterate over an entity list, looking at each entity for relevant components and processing every matching entity. The following system will process any entity with "position" and "velocity" components, updating the position based on the velocity. 

```lua
local updateMotion = System(
    { 'position', 'velocity' },
    function (p, v, dt)
        p.x = p.x + v.x * dt
        p.y = p.y + v.y * dt
    end)
```

Invoke a system. Pass in an entities list, followed by any optional arguments.

```lua
function love.update (dt)
    updateMotion(entities, dt)
end
```

## API

The API consists of a single function named `System`.

### System(aspects, process) -> function (entities, ...)

- `aspects`: A list of keys which must be present in entities in order to
  process them. For each "aspect", the `process` function will receive one
  argument containing the matching component.

  **pseudo-components**

  In addition to component keys, `aspects` may also contain some special
  "pseudo-component" keys. The following pseudo-components are provided:

  - `_entity`: The entity containing the components being processed.
  - `_entities`: The entities list being processed.
  - `_index`: The index of the current entity within the entities list.

  **choices**

  An aspect may contain several component keys delimited by pipe characters,
  for example:

  `name|label|title`

  These aspects will resolve to the first component found. If none of the
  components are found, the entity will not be processed.

  **sigils**

  An aspect may begin with the special characters `?`, `-` or `!`.

  If the aspect begins with `?`, it is optional, and will not prevent the
  entity from being processed even if no matching components are found.

  If an aspect begins with `-`, the component is suppressed from the arguments
  list passed to the process function. This is useful for components that only
  help determine whether to process an entity, but the value of the component
  is not needed within the process function.

  If the aspect begins with `!`, all keys listed in the aspect must not be
  present in an entity in order to process it. These aspects have no effect
  on the arguments list.

- `process`: A function that will process components. It should take one
  parameter for each value in the `aspects` list, plus any number of additional
  parameters for optional arguments passed to the returned function following
  the entities list.

  The `process` function may return up to two values. The first return value
  identifies entities to be removed from the list, and the second contains
  new entities to append to the list.

  If the first return value is `true`, the entity being processed will be
  removed from the entities list. If it is a table of entities, all entities
  in the table will be removed.

  The second return value, if present, should be a table of entities to append
  to the entities list.
  
  Entities will be removed and appended as soon as no systems are running.

The `System` factory function returns a function representing your system.
Call this returned function as needed; for example, in your update or draw
routine. It requires an entities list as the first argument, followed by any
number of optional arguments to be passed along to the `process` function.
