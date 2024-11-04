--[[
A very basic serializor mixin for LowerClass.

This utilizes Serpent https://github.com/pkulchenko/serpent/tree/master in order to serialize data

==== Creating a class that is serializable. ====
local SerializeMixin = require "SerializeMixin"
local Class = require "LowerClass"

local ClassA = Class("ClassA", SerializeMixin)

function ClassA:__init(a, b)
  self.a = a
  self.b = b
end

==== Serializing an object ====
local objA = ClassA:new(1, 5)
local dat = objA:serialize()

==== Deserializing an object ====
local objB = ClassA:new()
objB:deserialize(dat)

]]


local serpent = require 'lib.serpent'

-- Serialization mixin
local SerializableMixin = {
    -- Serializes the object into a single-line Lua-readable string (requires 'serpent' library)
    serialize = function(self)
        return serpent.block(self:toTable())
    end,

    -- Converts the object's properties into a plain table format
    toTable = function(self)
        local result = {}
        for k, v in pairs(self) do
            if type(v) ~= "function" and k ~= "class" then  -- Exclude functions and class reference
                result[k] = v
            end
        end
        return result
    end,

    -- Deserializes from a table and applies the properties to the object
    deserialize = function(self, dataTable)
        local ok, dataTable = serpent.load(dataTable)
        if not ok then
            error("Failed to deserialize data: " .. dataTable)
        end
        for k, v in pairs(dataTable) do
            self[k] = v
        end
    end,

    included = function(self, class)
        print(class.name .. " has included SerializableMixin.")
    end,
}

return SerializableMixin
