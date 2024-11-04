## LowerClass
A simple OOP library for Lua. It has complex inheritance, metamethod support, and weak mixin support.

Note* This is heavily inspired by [middleclass](https://github.com/kikito/middleclass) by kikito. Many parts of the code are directly copied, and the core functionallity is modeled after it. I love MiddleClass but found a few features limiting, hence why LowerClass was developed. 

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
- `LowerClass:new(name: str, ...: mixin|class) => Class` - Generates a new class with the given name. Remaining args are individually passed to Class:include()
- `LowerClass(...)` - Wraps LowerClass:new()

Class
- `Class:new(...) => Instance` - Generates a new instance of a class, passing all args __init(...)
- `Class(...)` - Wraps Class:new()
- `Class:include(mixin|class)` - Either mixes in a table or adds the passed class as a parent of the calling class.
- `Class:is(otherClass) => Boolean` - Checks if the calling class inherits (is a sub-child) of otherClass.
- `Class.name` - name of the class

Instance
- `Instance:is(otherClass) => Boolean` Checks if instance inherits (is a sub-child) of otherClass.
- `Instance.class` The instance's class.

# Changes

As this is heavily inspired, I would highly recommend looking at [MiddleClass's Wiki](https://github.com/kikito/middleclass/wiki) before getting started. You will find a lot of great info there. Below I will simply go over the primary face-value differences.

## No-Static

MiddleClass's static functionallity was removed. Whilst a cool feature, overall it added more complexity that it was worth. Instead all functions defined in a class are now both static and instance based.

MiddleClass:
```lua
local TestClass = class('Test')

TestClass.static.exampleStaticFunc()
  print('This is a static function')
end

TestClass.exampleStaticFunc()
```

LowerClass:
```lua
local TestClass = class('Test')

TestClass.exampleFunc()
  print('This is an example function')
end

TestClass.exampleFunc()
```

## Multi-Inheritance

MiddleClass only supported having a single parent class. This was neat, but I really like having multi-class inheritance. 

'super' has been removed from the class dictionary. This was previously a reference to the active class' parent. Instead of using super(), just directly reference the class.

MiddleClass:

```lua
local ClassA = class('ClassA')
local ClassB = class('ClassB', ClassA)

ClassB.static.exampleStaticFunc(self)
  print('This is class ' .. self.name .. ', my parent is ' .. self.super.name .. '.')
end

ClassB:exampleStaticFunc()
```

LowerClass:
```lua
local ClassA = class('ClassA')
local ClassB = class('ClassB', ClassA)

ClassB.exampleFunc(self)
  print('This is class ' .. ClassB.name .. ', my parent is ' .. ClassA.name .. '.')
end

ClassB:exampleStaticFunc()
```

## Inheritance / Mixins

Tied closely to the above, LowerClass simplifies both how mixins and inheritance works. [Mixins](https://github.com/kikito/middleclass/wiki/Mixins) behave exactly the same. With the support of multi-inheritance, the include function now supports adding a parent class by passing it as the variable.

LowerClass:
```lua
local testMixin = {
  fly = function(self)
    print('Flapping like a bird')
  end
}

local ClassA = class('ClassA')
local ClassB = class('ClassB')

ClassB:include(ClassA) -- ClassA is now a parent of ClassB. ClassB will now inherit all functions added to ClassA.
ClassA:include(testMixin) -- Added the fly function to ClassA, and by proxy ClassB.
```

## is / isInstanceOf

MiddleClass offers the ability to check if an instance/class is a part of another class, but this utilized the static method. I condensed both obj:isInstanceOf() and class:isSubclassOf() down to class:is() / obj:is(). 

*Please note the new is() function will be the highest preformance impacting change. This is simply because of looping over every parent. If you keep class heiracrhy simple, it shouldn't really impact preformance.

MiddleClass:
```lua
local ClassA = class('ClassA')
local ClassB = class('ClassB', ClassA)

local objA = ClassA:new()
local objB = ClassB:new()

print(objA:isInstanceOf(ClassA)) -- True
print(objA:isInstanceOf(ClassB)) -- False
print(objB:isInstanceOf(ClassA)) -- True
print(objB:isInstanceOf(ClassB)) -- True

print(ClassA:isSubclassOf(ClassB)) -- False
print(ClassB:isSubclassOf(ClassA)) -- True
```

LowerClass:
```lua
local ClassA = class('ClassA')
local ClassB = class('ClassB', ClassA)

local objA = ClassA:new()
local objB = ClassB:new()

print(objA:is(ClassA)) -- True
print(objA:is(ClassB)) -- False
print(objB:is(ClassA)) -- True
print(objB:is(ClassB)) -- True

print(ClassA:is(ClassB)) -- False
print(ClassB:is(ClassA)) -- True
```

## Internal Storage

MiddleClass stored all variables associated with a class inside the class. LowerClass shifts all important internal class data into a localized weak-keyed table. Whilst this won't impact user interaction, its a significant enough change to simply note it.

This includes:
- Class Heirarchy (parent/children)
- Class Variables
