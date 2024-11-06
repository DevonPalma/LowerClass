--[[
-- ------------------------------- ReInitMixin ------------------------------ --

This mixin allows re-initialization of an instance of a class, supporting two main modes:
1. Chainable (default): Enables chainable builder-style initialization for nested instances.
2. Non-Chainable: Disables chaining, useful for standalone re-initialization without breaking patterns.

-- ------------------------ Chainable Mode (default) ------------------------ --

When `chainable = true` (default), classes mixed with `ReInitMixin` can be used in a chainable builder pattern.

Usage Example:

```lua
    local BuildableClass = LowerClass("BuildableClass", ReInitMixin)
    function BuildableClass:__init(x, y)
        self.x = x
        self.y = y
    end

    local MainClass = LowerClass("MainClass")
    function MainClass:__init()
        self.vector = BuildableClass:new(0, 0)
    end
```

Chainable builder:

```lua
    local myObj = MainClass:new()
        :vector(3, 3)           -- Sets vector values via chained builder
    print(myObj.vector.x, myObj.vector.y) -- Output: 3, 3
```

The above allows vector in MainClass to be reinitialized:

```lua
    myObj:vector(5, 4)
    print(myObj.vector.x, myObj.vector.y) -- Output: 5, 4
```

⚠ Note: Chainable mode is designed for nested class variables and won’t support re-initializing loose variables directly:

```lua
    -- This will cause an error when `chainable = true`
    local vector = BuildableClass:new(0, 0)
    vector(3, 4)

    -- Similarly, dot calling a variable will also error.

    myObj.vector(3, 4)
```

-- --------------------------- Non-Chainable Mode --------------------------- --

To disable chainable builder support, pass false when including ReInitMixin:

```lua
    local BuildableClass = LowerClass("BuildableClass", ReInitMixin(false))
```

In this mode, re-initialization is supported for individual instances but does not allow chaining.

Usage Example (Non-Chainable Mode):

```lua
    local vector = BuildableClass:new(0, 0)
    vector(3, 4)
    print(vector.x, vector.y) -- Output: 3, 4
```

You can still use this mode for re-initialization within a class, but without chaining:

```lua
    local myObj = MainClass:new()
    myObj.vector(3, 3)
    print(myObj.vector.x, myObj.vector.y) -- Output: 3, 3
```

⚠ Note: chaining is not supported:

```lua  
    -- This will cause an error in non-chainable mode
    local myObj = MainClass:new()
        :vector(4, 4)
```
]]

return function(Chainable)
    if Chainable == false then
        return {
            __call = function(mixinObj, ...)
                mixinObj:__init(...)
                return mixinObj
            end
        }
    else
        return {
            __call = function(mixinObj, parentObj, ...)
                mixinObj:__init(...)
                return parentObj
            end
        }
    end
end
