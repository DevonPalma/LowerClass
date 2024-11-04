## LowerClass
A simple OOP library for Lua. It has complex inheritance, metamethod support, and weak mixin support.

Note* This is heavily inspired by [middleclass](https://github.com/kikito/middleclass) by kikito. Many parts of the code are directly copied, and the core functionallity is modeled after it.

## Quick Look

```lua
local class = require 'lowerclass'

local Fruit = class('fruit')

function Fruit:__init(sweetness)
  self.sweetness = sweetness
end

local Colorful = class('colorful)

function Colorful:__init(color)
  self.color = color
end

local Lemon = class('Lemon', Fruit, Colorful)

function Lemon:__init(color, sweetness)
  Fruit.__init(self, sweetness)
  Colorful.__init(self, color)
end

local lemon = Lemon:new("blue", 10)
```

# Changes

As this is heavily inspired, I would highly recommend looking at [MiddleClass's Wiki](https://github.com/kikito/middleclass/wiki) before getting started. You will find a lot of great info there. Below I will simply go over the primary face-value differences.

## No-Static

MiddleClass's static functionallity was removed. I felt it was a bit unnecessary to do. Instead whenever you declare a function for a class, it is then accessible by the class and instance.

MiddleClass:
```lua
local TestClass = class("Test")

TestClass.static.exampleStaticFunc()
  print("This is a static function")
end

TestClass.exampleStaticFunc()
```

LowerClass:
```lua
local TestClass = class("Test")

TestClass.exampleFunc()
  print("This is an example function")
end

TestClass.exampleFunc()
```

## Multi-Inheritance

MiddleClass only supported having a single parent class. This was neat, but I really like having multi-class inheritance. 

This however resulted in "super" being removed from the class. This was previously a reference to the active class' parent. Now, you should simply just directly reference the class.

MiddleClass:

```lua
local ClassA = class("ClassA")
local ClassB = class("ClassB", ClassA)

ClassB.static.exampleStaticFunc(self)
  print("This is class " .. self.name .. ", my parent is " .. self.super.name .. ".")
end

ClassB:exampleStaticFunc()
```

LowerClass:
```lua
local ClassA = class("ClassA")
local ClassB = class("ClassB", ClassA)

ClassB.exampleFunc(self)
  print("This is class " .. ClassB.name .. ", my parent is " .. ClassA.name .. ".")
end

ClassB:exampleStaticFunc()
```

## Inheritance / Mixins

Tied closely to the above, LowerClass simplifies both how mixins and inheritance works. [Mixins](https://github.com/kikito/middleclass/wiki/Mixins) behave exactly the same. With the support of multi-inheritance, the include function now supports adding a parent class by passing it as the variable.

LowerClass:
```lua
local testMixin = {
  fly = function(self)
    print("Flapping like a bird")
  end
}

local ClassA = class("ClassA")
local ClassB = class("ClassB")

ClassB:include(ClassA) -- ClassA is now a parent of ClassB. ClassB will now inherit all functions added to ClassA.
ClassA:include(testMixin) -- Added the fly function to ClassA, and by proxy ClassB.
```

## is / isInstanceOf

MiddleClass offers the ability to check if an instance/class is a part of another class, but this utilized the static method. I condensed both obj:isInstanceOf() and class:isSubclassOf() down to class:is() / obj:is()

MiddleClass:
```lua
local ClassA = class("ClassA")
local ClassB = class("ClassB", ClassA)

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
local ClassA = class("ClassA")
local ClassB = class("ClassB", ClassA)

local objA = ClassA:new()
local objB = ClassB:new()

print(objA:is(ClassA)) -- True
print(objA:is(ClassB)) -- False
print(objB:is(ClassA)) -- True
print(objB:is(ClassB)) -- True


print(ClassA:is(ClassB)) -- False
print(ClassB:is(ClassA)) -- True
```
