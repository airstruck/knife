# knife.memoize

A memoization function.

```lua
local Memoize = require 'knife.memoize'
```

## Memoize (func)

Memoize a function.

### Parameters

- *function* **func**

  Function to memoize.

### Returns

- Memoized function.

### Example

```lua
function fibonacci (n)
  return n < 2 and n or fibonacci(n - 1) + fibonacci(n - 2)
end

fibonacci = Memoize(fibonacci)
```

## Caveats/features

- For background information on memoization, see
  [kikito/memoize](https://github.com/kikito/memoize.lua).

- Unlike other popular implementations, this memoize function accepts nil
  values in arguments lists as well as in return values.

- This implementation uses weak tables when caching results. If a table is
  passed to a memoized function and at some point nothing references that
  table, the associated cached result may be cleared. This makes sense
  since a cached result is not retrievable once an argument associated
  with it no longer exists.
