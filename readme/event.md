# knife.event

Dispatch and handle events.

## Example usage

Require the library.

    local Event = require 'knife.event'

Intercept Love events and callbacks.

    Event.injectDispatchers(love.handlers)
    Event.injectDispatchers(love, { 'load', 'update', 'draw' })

Define an event handler.

    Event.on('update', function (dt)
        myGame:updateStuff(dt)
    end)

Define a handler and store it in a local variable.

    local keyHandler = Event.on('keypressed', function (b, s, r)
        myGame:mashButtons(b, s, r)
    end)

Remove a handler.

    keyHandler:remove()

Dispatch a custom event.

    Event.dispatch('pebkac', keyboard, chair)

## Caveats/features

- Returning `false` from an event handler will cause other handlers not to
  process the event.

- Events are processed in a last-in, first-out order. This means the last
  handler registered for an event type can prevent all other handlers from
  processing the events, and the first handler added can't prevent any other
  handlers from processing them.
