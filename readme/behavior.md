# knife.behavior

A state machine manager.

## Example usage

Require the library.

    local Behavior = require 'knife.behavior'

Define a table containing states. A "default" state is required.

    local states = {
        default = {
            { duration = 0, after = 'idle' },
        },
        idle = {
            { sprite = 'human.idle.a', duration = 3 },
            { sprite = 'human.idle.b', duration = 1 },
            { sprite = 'human.idle.a', duration = 2 },
            { sprite = 'human.idle.c', duration = 1, action = think },
        },
        walk = {
            { sprite = 'human.run.a', duration = 0.2 },
            { sprite = 'human.run.b', duration = 0.2 },
            { sprite = 'human.run.c', duration = 0.2 },
            { sprite = 'human.run.b', duration = 0.2 },
        },
    }

The items in each state are called "frames." Each frame may contain the
following keys:

- **action**: a function to execute at the beginning of the frame. It takes the
  behavior as its first argument and an optional "subject" as the second.

- **after**: the name of a state to enter after the current frame.

- **duration**: number of seconds to wait before advancing to the next frame.

- any arbitrary user-defined keys ("sprite" in this example).

Create a behavior object:

    local behavior = Behavior(states)

Update the behavior object with the time delta:

    function love.update (dt)
        behavior:update(dt)
    end

## API

### Behavior (states [, subject]) -> behavior

Creates a new behavior object. An optional `subject` is passed as a second
argument to any *action* functions.

### behavior:update (dt)

Update the behavior object with a time delta. When the elapsed time exceeds
the current frame *duration*, the behavior will advance to the next frame.

If the current frame contains an *after* key, the next frame will be the first
frame in the state named by the *after* key.

Otherwise, the behavior will advance to the next frame in the current state.
If there is no next frame in the current state, the behavior will loop back
to the first frame in the current state.

### behavior:setState (state [, index])

Set the current frame to the named `state` at the given `index`, or to the
first frame in the named `state` if `index` is omitted.

### behavior.state

The name of the current state.

### behavior.index

The index of the current frame within the current state.

### behavior.frame

The current frame. May be used to access user-defined keys.

## Caveats/features

Behaviors do not modify the `states` table in any way. A single `states` table
may be used for multiple entities.

Behavior fields such as `state`, `index`, and `frame` should be treated as
read-only. Modifying these may give unexpected results. Use `setState` instead.
