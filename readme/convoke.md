# knife.convoke

Flatten async code with coroutines.

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

Convoke can be used to remedy that. The example above can be written like this:

```lua
Convoke(function (continue, wait)
    print 'fading in'
    Timer.after(1, continue())
    wait()
    print 'showing splash screen'
    Timer.after(1, continue())
    wait()
    print 'showing title screen'
    Timer.after(1, continue())
    wait()
    print 'playing demo'
end)()
```

## API

The `Convoke` function takes a **callback** function as its sole argument, and
returns a **future** function.

The first argument passed to the callback is a **continue** function. Invoke
this function to obtain a continuation function. Generally, this function
should be passed into an asynchronous function as the callback, as in the
example above.

The second argument passed to the callback is a **wait** function. Call this
function to resume execution. Any arguments passed into the continuation
function returned from `continue()` (the callback arguments) are returned
from `wait`.

The **future** function returned from a call to `Convoke` has nearly the same
API as `Convoke` itself, with two additional behaviors:

- Calling the future function with no arguments executes the routine.

- Calling the future function with a callback once the routine has been
  executed will cause it to run as soon as the previous section has run,
  or immediately if the previous section has finished running.
