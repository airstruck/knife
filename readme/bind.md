# knife.bind

Bind arguments to functions.

```lua
local Bind = require 'knife.bind'
```

## Bind (func, ...)

Bind arguments to a function.

### Parameters

- *function* **func**

  Function to bind arguments to.

- *mixed* **...**

  Arguments to bind to the function.

### Returns

- Bound function. Invokes **func** with bound arguments, followed by any
  arguments passed when invoking the bound function.

### Example

```lua
local function speak (person, phrase, audience)
  print(person .. ' says ' .. phrase .. ' to ' .. audience)
end

local bobGreet = Bind(speak, 'Bob', 'hi')

bobGreet('you') -- prints "Bob says hi to you"
```
