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
Chain(
    function (continue)
        print 'fading in'
        Timer.after(1, continue)
    end,
    function (continue)
        print 'showing splash screen'
        Timer.after(1, continue)
    end,
    function (continue)
        print 'showing title screen'
        Timer.after(1, continue)
    end,
    function ()
        print 'playing demo'
    end
)()
```

Chains can be condensed with small generator functions:

```lua
local function TimedText (seconds, text)
    return function (continue)
        print(text)
        Timer.after(seconds, continue)
    end
end

Chain(
    TimedText(1, 'fading in'),
    TimedText(1, 'showing splash screen'),
    TimedText(1, 'showing title screen'),
    TimedText(1, 'showing demo')
)()
```

## API

The `Chain` function takes zero or more **link** functions as its arguments,
and returns a **chain** function, which can be used to add more links to the
chain and to run the chain.

The first argument passed to the **link** is a **continue** function. Call
this function to process the next link in the chain. Generally, this function
should be passed into an asynchronous function as the callback, as in the
examples above.

A **link** may also return another **chain** instead of calling **continue**.
In this case, the next link (if any) will be appended to the returned chain.
This allows for the creation of APIs with functions that return chains rather
than accepting callbacks. If a **link** returns anything, it must be a **chain**.

The **chain** function returned from a call to `Chain` has nearly the same API
as `Chain` itself, with two additional behaviors:

- The **callback** passed to chain functions may receive extra arguments
  after the **continue** argument. The values of these arguments come from any
  arguments passed into the continue function from the previous link.

- Calling the chain function with no arguments or an initial `nil`
  executes the entire chain. Any arguments after the initial `nil`
  are passed into the first **link**, after the **continue** argument.

