--[[
A very basic clonable mixin for LowerClass.

This allows objects to create a deep copy of themselves.

==== Creating a class that is clonable ====
local ClonableMixin = require "ClonableMixin"
local Class = require "LowerClass"

local ClassA = Class("ClassA", ClonableMixin)

function ClassA:__init(a, b)
  self.a = a
  self.b = b
end

==== Cloning an object ====
local objA = ClassA:new(1, 5)
local objClone = objA:clone()

]]

-- Clonable mixin
--- @class ClonableMixin
local ClonableMixin = {
    -- Recursively creates a deep copy of the object
    clone = function(self)
        local function deepCopy(orig)
            local copy
            if type(orig) == 'table' then
                copy = {}
                for orig_key, orig_value in pairs(orig) do
                    copy[deepCopy(orig_key)] = deepCopy(orig_value)
                end
                setmetatable(copy, getmetatable(orig))
            else -- number, string, boolean, etc
                copy = orig
            end
            return copy
        end

        -- Return a deep copy of the instance, excluding the class reference
        local copy = deepCopy(self:toTable())
        setmetatable(copy, getmetatable(self))
        return copy
    end,

    -- Converts the object's properties into a plain table format for cloning
    toTable = function(self)
        local result = {}
        for k, v in pairs(self) do
            if type(v) ~= "function" and k ~= "class" then  -- Exclude functions and class reference
                result[k] = v
            end
        end
        return result
    end,

    included = function(self, class)
        print(class.name .. " has included ClonableMixin.")
    end,
}

return ClonableMixin
