
--[[
A convoluted mixin that is a bit weird to use but allows a really powerful
Builder pattern for classes.

To Use:

--- Set up the class that will be using ReInitMixin
local BuildableClass = Class("BuildableClass", ReInitMixin)
function BuildableClass:__init(x, y)
    self.x = x
    self.y = y
end

--- Set up the class that will utilize the mixin class
local MainClass = Class("MainClass")
function MainClass:__init()
    self.vector = BuildableClass:new(0, 0)
end

--- The powah:
local myObj = MainClass:new()
    :vector(3, 3)  -- Using the ReInit as a builder
print(myObj.var.x, myObj.var.y) -- 3, 3

myObj:vector(5, 4)
print(myObj.var.x, myObj.var.y) -- 5, 4
]]


return {
    __call = function(mixinObj, parentObj, ...)
        mixinObj:__init(...)
        return parentObj
    end
}

