# knife.base

A base class for class-based OOP.

## Example usage

Require the library.

```lua
local Base = require 'knife.base'
```

Call Base:extend() to create a new class.

```lua
local Thing = Base:extend()
```

Call extend on your classes to create new subclasses.

```lua
local Bullet = Thing:extend()
```

Give your classes default properties.

```lua
local Barrel = Thing:extend({ explosionRadius = 10 })
-- or
local Barrel = Thing:extend()
Barrel.explosionRadius = 10
```

Define constructors for your classes.

```lua
function Barrel:constructor (radius)
    self.explosionRadius = radius
end
```

Create methods on your classes.

```lua
function Barrel:explode ()
    Game:spawnExplosion(self.explosionRadius)
end
```

Instantiate your classes.

```lua
local barrel = Barrel(500)
barrel:explode()
```

## Caveats/features

- All classes extend the base class. The base class has only two members,
  `extend` and `constructor`.

- All class members are visible to both the class and the instance -- there is
  no separation between 'static' and 'instance' scopes. It's up to the user to
  document and use members appropriately.

  Because of this, `object:extend()` will create a subclass of an object, which
  can be instantiated. This is probably not useful.

- Just for kicks, any return values from the constructor come back as return
  values when instantiating a class, after the instance itself.
