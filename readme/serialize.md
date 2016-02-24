# knife.serialize

Store data structures as strings.

## Example usage

Require the module.

```lua
local Serialize = require 'knife.serialize'
```

Create an object to serialize.

```lua
local data = { name = 'Bob', level = 1, dead = false,
    inventory = { 'spoon', 'fork', 'knife' } }
```

Serialize the object.

```lua
local savegame = Serialize(data)
```

Now `savegame` holds a string containing a script that, when loaded with
`loadstring`, or when saved to a file and loaded with `require` or `dofile`,
will produce a table equivalent to the original `data` table.

## Safe deserialization

When deserializing data from an untrusted source, the deserialized function should be sandboxed before running it.

```lua
local data = setfenv(loadstring(serialized), {})()
```

## Binary serialization

Under LuaJIT, `string.dump` can be used to produce binary output instead of text.

```lua
local serialized = string.dump(loadstring(Serialize(data)), true)
```

The binary output can be deserialized in exactly the same way as the normal textual output.

## Caveats/features

- Supports data structures with circular references and self references.
  Supports positive and negative infinity, and NaN with sign bit preserved.

- Only tables, strings, numbers, and booleans will be stored. Functions,
  threads, and userdata will not be stored. In order to store a table field,
  both the key and the value must have storable types.

- Will not throw any errors or log any warnings. Data that cannot be stored
  will simply be omitted.
