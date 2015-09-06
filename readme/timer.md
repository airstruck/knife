# knife.timer

Create timers and tweens.

## Example usage

Require the library.

    local Timer = require 'knife.timer'

### Tweens

Create some objects with values to tween.

    local vehicle = { fuel = 99, position = { x = 10, y = 30 } }
    local overlay = { opacity = 0, color = { 0, 0, 0 } }

Create a tween.

    -- this tween takes 10 seconds to complete
    Timer.tween(10, {
        -- vehicle's fuel is depleted as it moves from left to right
        [vehicle] = { fuel = 0 },
        [vehicle.position] = { x = 100 },
        -- meanwhile, overlay fades in as color changes from black to red
        [overlay] = { opacity = 1 },
        [overlay.color] = { 255, 0, 0 },
    })

Update all tweens.

    function love.update (dt)
        Timer.update(dt)
    end

## API

#### Timer.after (delay, callback) -> timer

Create a delay timer and insert it into the default group.

#### Timer.every (interval, callback) -> timer

Create an interval timer and insert it into the default group.

#### Timer.prior (cutoff, callback) -> timer

Create a continuous timer and insert it into the default group.

#### Timer.tween (duration, definition) -> timer

Create a tween timer and insert it into the default group.

#### Timer.update (dt [, timers])

Update all timers in group `timers`, or in the default group if omitted.

#### Timer.clear ([timers])

Clear all timers from group `timers`, or from the default group if omitted.

#### timer:group ([timers])

Insert the timer into `timers` and remove it from its current group. To update
timers in this group, call `Timer.update(dt, timers)`. Uses the default group
if `timers` is not provided.

Applies to all timers.

#### timer:remove ()

Removes the timer from its current group, preventing it from receiving updates.

Applies to all timers.

#### timer:finish (callback)

Set a callback to invoke when the timer is finished. The callback takes the
timer as the first argument and the "lateness" (elapsed time minus duration
specified) as the second argument.

Applies to all timers except those created with `Timer.after`.

#### timer:count (number)

Limit the number of times a timer can run.

Applies only to timers created with `Timer.every`.

#### timer:ease (easingFunction)

Use a custom easing function for this tween instead of the default linear
easing function. Accepts functions matching the signatures of those found in
[EmmanuelOga/easing](https://github.com/EmmanuelOga/easing).

Applies only to timers created with `Timer.tween`.

## Caveats/features

- In the interest of performance, simultaneously applying multiple tweens
  that affect the same values produces undefined behavior. If you need tweens
  with the ability to interrupt/override other tweens, consider using
  [rxi/flux](https://github.com/rxi/flux) instead, which provides this behavior
  at the expense of greater memory overhead.
