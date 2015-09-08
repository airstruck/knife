# knife.chain

Flatten async code with chained functions.

## Overview

Heavy use of callbacks can lead to deeply nested, hard to maintain code:

```lua
print 'fading in'
Timer.after(1, function ()
    print 'showing splash screen'
    Timer.after(1, function ()
        print 'showing title screen'
        Timer.after(1, function ()
            print 'playing demo'
        end)
    end)
end)
```

Chain can be used to remedy that. The example above can be written like this:

```lua
Chain(function (continue)
    print 'fading in'
    Timer.after(1, continue)
end)(function (continue)
    print 'showing splash screen'
    Timer.after(1, continue)
end)(function (continue)
    print 'showing title screen'
    Timer.after(1, continue)
end)(function (continue)
    print 'playing demo'
end)()
```

## API

The `Chain` function takes a **callback** function as its sole argument, and
returns a **link** function.

The first argument passed to the callback is a **continue** function. Invoke
this function to process the next link in the chain. Generally, this function
should be passed into an asynchronous function as the callback, as in the
example above.

The **link** function returned from a call to `Chain` has nearly the same API
as `Chain` itself, with two additional behaviors:

- Calling the link function with no arguments executes the entire chain.

- The **callback** passed to link functions may receive extra arguments
  after the **continue** argument. The values of these arguments come from any
  arguments passed into the continue function from the previous link.

## Caveats/features

- Chains can be run multiple times.

- References to any link in the chain are identical. For example:

  ```lua
  local c1 = Chain(function (continue)
      print 'link one'
      continue()
  end)

  local c2 = c1(function (continue)
      print 'link two'
      continue()
  end)

  assert(c1 == c2) -- passes
  ```
