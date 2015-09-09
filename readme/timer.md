# knife.timer

Create timers and tweens.

```lua
local Timer = require 'knife.timer'
```

## Timer.after (delay, callback) -> timer

Create a delay timer and insert it into the default group. The `callback`
will execute once after `delay` seconds.

### Parameters

- *number* **delay**

  Number of seconds to wait before executing the callback.

- *function* **callback (timer, lateness)**

  Callback to execute. Receives the timer instance as the first parameter and
  the number of seconds it fired after the specified delay as the second.

### Returns

- A timer instance.

### Example

```lua
print 'Self-destructing in 5 seconds.'
Timer.after(5, function () print 'Boom!' end)
```

## Timer.every (interval, callback) -> timer

Create an interval timer and insert it into the default group. The `callback`
will execute once every `interval` seconds.

### Parameters

- *number* **interval**

  Number of seconds to wait before executing the callback.

- *function* **callback (timer, lateness)**

  Callback to execute. Receives the timer instance as the first parameter and
  the number of seconds it fired after the specified interval as the second.

### Returns

- A timer instance.

### Example

```lua
print 'Explosives set!'
Timer.every(1, function () print 'Tick!' end)
```

## Timer.prior (cutoff, callback) -> timer

Create a continuous timer and insert it into the default group.The `callback`
will execute once every update until `cutoff` seconds.

### Parameters

- *number* **cutoff**

  Number of seconds to execute the callback.

- *function* **callback (timer, dt)**

  Callback to execute. Receives the timer instance as the first parameter and
  the time delta since the last update as the second.

### Returns

- A timer instance.

### Example

```lua
print 'Going up!'
elevator.y = 500
Timer.prior(10, function (timer, dt) elevator.y = elevator.y - dt end)
```

## Timer.tween (duration, definition) -> timer

Create a tween timer and insert it into the default group.

### Parameters

- *number* **duration**

  Number of seconds until tween is complete.

- *table* **definition**

  Keys are existing tables containing values to tween, fields are new tables
  containing target values.

### Returns

- A timer instance.

### Example

```lua
-- Create some objects with values to tween.

local vehicle = { fuel = 99, position = { x = 10, y = 30 } }
local overlay = { opacity = 0, color = { 0, 0, 0 } }

-- Create a tween.

-- This tween takes 10 seconds to complete
Timer.tween(10, {
    -- Vehicle's fuel is depleted as it moves from left to right
    [vehicle] = { fuel = 0 },
    [vehicle.position] = { x = 100 },
    -- Meanwhile, overlay fades in as color changes from black to red
    [overlay] = { opacity = 1 },
    [overlay.color] = { 255, 0, 0 },
})
```

## Timer.update (dt [, timers])

Update all timers in group `timers`, or in the default group if omitted.

### Parameters

- *number* **dt**

  Number of seconds since last update.

- *table* **timers**

  Optional group of timers to update. Updates the default group if omitted.

### Example

```lua
function love.update (dt)
    Timer.update(dt)
end
```

## Timer.clear ([timers])

Clear all timers from group `timers`, or from the default group if omitted.

### Parameters

- *table* **timers**

  Optional group of timers to clear. Clears the default group if omitted.

### Example

```lua
Timer.clear()
```

## timer:group ([timers])

Insert the timer into `timers` and remove it from its current group. To update
timers in this group, call `Timer.update(dt, timers)`. Uses the default group
if `timers` is not provided.

Applies to all timers.

### Parameters

- *table* **timers**

  Optional timer group. Inserts timer into the default group if omitted.

### Example

```lua
local bombTimers = {}

Timer.every(1, function () print 'Tick!' end)
    :group(bombTimers)
```

## timer:limit (runs)

Limit the number of times a timer will run.

Applies only to timers created with `Timer.every`.

### Parameters

- *number* **runs**

  Number of times the timer's callback will execute.

### Example

```lua
Timer.every(1, function () print 'Tick!' end)
    :limit(5)
```

## timer:finish (callback)

Set a callback to invoke when the timer is finished.

Applies to all timers except those created with `Timer.after`.

### Parameters

- *function* **callback (timer, lateness)**

  Function to execute when the timer is finished. The callback takes the
  timer as the first argument and the "lateness" (elapsed time minus duration
  specified) as the second argument.

### Example

```lua
Timer.every(1, function () print 'Tick!' end)
    :finish(function () print 'Boom!' end)
    :limit(5)
```

## timer:ease (easing)

Use a custom easing function for this tween instead of the default linear
easing function.

Applies only to timers created with `Timer.tween`.

### Parameters

- *function* **easing (elapsed, initial, change, duration)**

  A function matching the signatures of those found in
  [EmmanuelOga/easing](https://github.com/EmmanuelOga/easing).

### Example

```lua
local Easing = require 'easing'

local overlay = { opacity = 0 }

Timer.tween(1, { [overlay] = { opacity = 1 } })
    :ease(Easing.outQuad)
```

## timer:remove ()

Removes the timer from its current group, preventing it from receiving updates.

Applies to all timers.

### Example

```lua
local ticker = Timer.every(1, function () print 'Tick!' end)

local function defuse ()
    ticker:remove()
end
```

## timer:register ()

Registers a previously removed timer.

Applies to all timers.

### Example

```lua
ticker:register()
```

## Caveats/features

- In the interest of performance, simultaneously applying multiple tweens
  that affect the same values produces undefined behavior. If you need tweens
  with the ability to interrupt/override other tweens, consider using
  [rxi/flux](https://github.com/rxi/flux) instead, which provides this behavior
  at the expense of greater memory overhead.
