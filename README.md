## LowerClass
A simple OOP library for Lua. It has complex inheritance, metamethod support, and weak mixin support.

> [!NOTE]
> This is heavily inspired by [middleclass](https://github.com/kikito/middleclass) by kikito. Many parts of the code are directly copied, and the core functionallity is modeled after it. I love MiddleClass but found a few features limiting, hence why LowerClass was developed. All changes can be found [here](https://github.com/DevonPalma/LowerClass/wiki/MiddleClass-vs-LowerClass)

## Quick Look

```lua
local class = require 'lowerclass'

local Fruit = class('fruit')

function Fruit:__init(sweetness)
  self.sweetness = sweetness
end

local Colorful = class('colorful')

function Colorful:__init(color)
  self.color = color
end

local Lemon = class('Lemon', Fruit, Colorful)

function Lemon:__init(color, sweetness)
  Fruit.__init(self, sweetness)
  Colorful.__init(self, color)
end

local lemon = Lemon:new('blue', 10)
```

## Quick Docs

LowerClass
- `LowerClass(name: str, ...: mixin|class) => Class` - Generates a new class.
- `LowerClass.type(obj: any) => string` - Returns the type of a passed object (Defaults to lua's type() if a non-class/instance type is passed)

Class
- `Class.name` - name of the class
- `Class:new(...) => Instance` - Generates a new instance of a class, passing all args __init(...)
- `Class:is(otherClass) => Boolean` - Checks if the calling class inherits (is a sub-child) of otherClass.
- `Class:include(...: mixin|class)` - Either mixes in a table or adds the passed class as a parent of the calling class.

Instance
- `Instance.class` Pointer to the instance's class
- `Instance:is(otherClass) => Boolean` Checks if instance inherits (is a sub-child) of otherClass.
- `Instance:include(...: mixin)` - Copies all functions from a mixin directyly to the calling instance.
