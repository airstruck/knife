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
    function (go)
        print 'fading in'
        Timer.after(1, go)
    end,
    function (go)
        print 'showing splash screen'
        Timer.after(1, go)
    end,
    function (go)
        print 'showing title screen'
        Timer.after(1, go)
    end,
    function (go)
        print 'playing demo'
        Timer.after(1, go)
    end
)()
```

Chains can be condensed with small generator functions:

```lua
local function TimedText (seconds, text)
    return function (go)
        print(text)
        Timer.after(seconds, go)
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

### Chain factory

The `knife.chain` module returns a `Chain` factory function.

The `Chain` factory takes zero or more **link** functions as its arguments,
and returns a **chain instance** function, which can be used to add links
to the chain or run the chain.

### Link functions

A **link** is a user-defined function passed into the `Chain` factory or a
**chain instance**.

The first argument passed to each **link** is a  function called **go**. Call
this function to process the next link in the chain. Generally, this function
should be passed into an asynchronous function as the callback, as in the
examples above. Any arguments passed to this function will be passed along
to the next link in the chain, after its **go** argument.

The **link** may receive extra arguments after the **go** argument. The values
of these arguments come from any arguments passed into the **go** function
from the previous link. The first link in the chain will receive any extra
arguments passed after the initial `nil` when executing the chain.

A **link** may return another **chain instance** instead of calling **go**.
In this case, the next link (if any) will be appended to the returned instance.
This allows for the creation of APIs with functions that return chains rather
than accepting callbacks.

Each **link** is responsible for either calling **go** (directly or indirectly)
or returning another **chain instance**. It should not do both. If a link returns
anything, it must be a **chain instance**.

### Chain instance

The **chain instance** returned from a call to `Chain` is a function sharing
the same API as `Chain`, with the following exception.

When invoked with no arguments or an initial `nil`, the first **link** of the
chain is executed. Any arguments after the initial `nil` are passed into the
first link, after the **go** argument.
