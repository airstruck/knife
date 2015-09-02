# knife.tween

Interpolate values with ease.

## Example usage

Require the library.

    local Tween = require 'knife.tween'

Create some objects with values to tween.

    local vehicle = { fuel = 99, position = { x = 10, y = 30 } }
    local overlay = { opacity = 0, color = { 0, 0, 0 } }

Create a tween.

    -- this tween takes 10 seconds to complete
    Tween(10, {
        -- vehicle's fuel is depleted as it moves from left to right
        [vehicle] = { fuel = 0 },
        [vehicle.position] = { x = 100 },
        -- meanwhile, overlay fades in as color changes from black to red
        [overlay] = { opacity = 1 },
        [overlay.color] = { 255, 0, 0 },
    })

Update all tweens.

    function love.update (dt)
        Tween.update(dt)
    end

## API

#### Tween (duration, definition) -> tween

Create a new tween and insert it into the default group.

#### Tween.update (dt [, tweens])

Update all tweens in group `tweens`, or in the default group if omitted.

#### tween:group (tweens)

Insert the tween into `tweens` and remove it from the default group. To update
tweens in this group, call `Tween.update(dt, tweens)`.

#### tween:ease (easingFunction)

Use a custom easing function for this tween instead of the default linear
easing function. Accepts functions matching the signatures of those found in
[EmmanuelOga/easing](https://github.com/EmmanuelOga/easing).

#### tween:finish (callback)

Set a callback to invoke when the tween is finished. The callback takes the
tween as the first argument and the "lateness" (elapsed time minus duration
specified) as the second argument .

## Caveats/features

- In the interest of performance, simultaneously applying multiple tweens
  that affect the same values produces undefined behavior. If you need tweens
  with the ability to interrupt/override other tweens, consider using
  [rxi/flux](https://github.com/rxi/flux) instead, which provides this behavior
  at the expense of greater memory overhead.
