# knife.system

An entity component system.

## Example usage

Require the library.

```lua
local System = require 'knife.system'
```

Define a system.

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

    System(aspects, process) -> function (entities, ...)

- `aspects`: A list of keys which must be present in entities in order to
  process them. For each "aspect", the `process` function will receive one
  argument containing the matching component.

  In addition to component keys, `aspects` may also contain some special
  "pseudo-component" keys. The following pseudo-components are provided:

  - `_entity`: The entity containing the components being processed.
  - `_entities`: The entities list being processed.
  - `_index`: The index of the current entity within the entities list.

- `process`: A function that will process components. It should take one
  parameter for each value in the `aspects` list, plus any number of additional
  parameters for optional arguments passed to the returned function following
  the entities list.

  The `process` function may return up to two values. The first return value
  identifies entities to be removed from the list, and the second contains
  new entities to append to the list.

  If the first return value is `true`, the entity being processed will be
  removed from the entities list. If it is a number, the entity at the
  corresponding index will be removed. If it is a table of numbers, all entities
  at the corresponding indices will be removed.

  The second return value, if present, should be a table of entities to append
  to the entities list.

The `System` factory function returns a function representing your system.
Call this returned function as needed; for example, in your update or draw
routine. It requires an entities list as the first argument, followed by any
number of optional arguments to be passed along to the `process` function.
