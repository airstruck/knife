# knife.event

Dispatch and handle events.

```lua
local Event = require 'knife.event'
```

## Event.on (name, callback) -> handler

Handle events of type `name` with `callback`.

### Parameters

- *string* **name**

  Type of events to handle.

- *function* **callback (...)**

  Callback to execute. Receives any number of optional parameters matching
  arguments passed when the event is dispatched. Callbacks may return `false`
  to prevent other handlers from handling the event.

### Returns

- An event handler instance.

### Example

```lua
local timeRemaining = 30
Event.on('update', function (dt)
    timeRemaining = timeRemaining - dt
end)
```

## Event.dispatch (name [, ...])

Dispatch an event of type `name` with optional arguments.

### Parameters

- *string* **name**

  Type of event to dispatch.

- *mixed* **...**

  Optional arguments to pass to event handlers.

### Example

```lua
if entity.health <= 0 then
    Event.dispatch('death', entity)
end
```

## Event.hook (target [, keys])

Hook dispatchers into `target` table in fields with matching `keys`, or all
fields if omitted.

### Parameters

- *table* **target**

  Table to hook dispatchers into.

- *table* **keys**

  Optional array of keys identifying fields to hook dispatchers into.

### Example

```lua
-- Intercept Love events and callbacks.
Event.hook(love.handlers)
Event.hook(love, { 'load', 'update', 'draw' })
```

## handler:remove ()

Remove an event handler.

### Example

```lua
-- Define a handler and store a reference in a local variable.
local deathHandler = Event.on('death', function (entity)
    print(entity.name .. ' died!')
end)

-- Remove the handler.
deathHandler:remove()
```
## handler:register ()

Register a previously removed event handler (newly created handlers are already
registered).

### Example

```lua
deathHandler:register()
```

## Caveats/features

- Returning `false` from an event handler will cause other handlers not to
  process the event.

- Events are processed in a last-in, first-out order. This means the last
  handler registered for an event type can prevent all other handlers from
  processing the events, and the first handler added can't prevent any other
  handlers from processing them.
