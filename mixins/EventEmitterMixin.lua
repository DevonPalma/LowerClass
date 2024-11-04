--[[
A basic event emitter mixin for LowerClass.

This mixin provides functionality to register, remove, and emit events.

==== Creating a class with event emission ====
local EventEmitterMixin = require "EventEmitterMixin"
local Class = require "LowerClass"

local ClassA = Class("ClassA", EventEmitterMixin)

function ClassA:__init()
  -- Initialize any required properties
end

==== Adding event listeners and emitting events ====
local objA = ClassA:new()

-- Register a listener
objA:on("someEvent", function(arg) print("Event triggered with:", arg) end)

-- Emit the event
objA:emit("someEvent", "data")
-- Output: Event triggered with: data

==== Removing event listeners ====
objA:off("someEvent")
]]

-- Event Emitter mixin
--- @class EventEmitterMixin
local EventEmitterMixin = {
    -- Registers a listener for a specific event
    on = function(self, event, callback)
        self.listeners = self.listeners or {}  -- Initialize listeners table if it doesn't exist
        self.listeners[event] = self.listeners[event] or {}
        table.insert(self.listeners[event], callback)
    end,

    -- Removes a specific listener for an event
    off = function(self, event, callback)
        if not self.listeners or not self.listeners[event] then return end
        for i, registeredCallback in ipairs(self.listeners[event]) do
            if registeredCallback == callback then
                table.remove(self.listeners[event], i)
                break
            end
        end
    end,

    -- Emits an event, calling all registered listeners
    emit = function(self, event, ...)
        if not self.listeners or not self.listeners[event] then return end
        for _, callback in ipairs(self.listeners[event]) do
            callback(...)
        end
    end,

    included = function(self, class)
        print(class.name .. " has included EventEmitterMixin.")
    end,
}

return EventEmitterMixin
