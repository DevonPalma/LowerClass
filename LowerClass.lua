-- -------------------------------------------------------------------------- --
--                                Customization                               --
-- -------------------------------------------------------------------------- --

--- If true, allows calling lowerclass() to create a new class
--- Cleaner, and can somewhat be reliable with EmmyLua annotations
local lowerclass_enableCallMetamethod = true

--- If true, allows calling lowerclass:new() to create a new class
--- Very reliable with EmmyLua annotations, but not as clean
local lowerclass_enableNewMethod = true

--- If true, allows calling myClass() to create an instance of a class
--- Cleaner, but very unreliable with EmmyLua annotations
---     If used, recommended to use the --[[@as <Class>]] annotation
local class_enableCallMetamethod = true

--- If true, allows calling myClass:new() to create an instance of a class
--- Very reliable with EmmyLua annotations, but not as clean
local class_enableNewMethod = true

-- -------------------------------------------------------------------------- --
--                                 Class Setup                                --
-- -------------------------------------------------------------------------- --

-- Define LowerClass with local weak tables for method storage
---@class lowerclass
---@overload fun(name: string, ...): Class|function
local lowerclass = {}

-- -------------------------------------------------------------------------- --
--                                    Core                                    --
-- -------------------------------------------------------------------------- --

-- Weak tables for storing method data
local classData = setmetatable({}, { __mode = "k" }) -- Stores class data

-- -------------------------------------------------------------------------- --
--                         Class Variable Declaration                         --
-- -------------------------------------------------------------------------- --

--- A very fancy way to create a better __index for a class
--- @param aClass Class
--- @param var table|function
--- @return table|function
local function __createIndexWrapper(aClass, var)
    if var == nil then
        return classData[aClass].lookupDict[name]
    elseif type(var) == "function" then
        return function(self, name)
            return classData[aClass].lookupDict[name] or var(self, name)
        end
    else -- if  type(f) == "table" then
        return function(self, name)
            return classData[aClass].lookupDict[name] or var[name]
        end
    end
end

--- Ensures a variable is propegated to all subclasses
--- @param aClass Class
--- @param name string
--- @param var any
local function __propegateClassVariable(aClass, name, var)
    var = name == "__index" and __createIndexWrapper(aClass, var) or var
    classData[aClass].lookupDict[name] = var

    for _, child in ipairs(classData[aClass].heirarchyData.children) do
        if classData[child].definedVariables[name] == nil then
            __propegateClassVariable(child, name, var)
        end
    end
end

-- Adds / Removes a variable from a class
---@param aClass Class
---@param name string
---@param var any
local function __declareClassVariable(aClass, name, var)
    -- print("Declared " .. tostring(aClass) .. "." .. tostring(name) .. " as " .. tostring(var))
    -- Set the var internally first
    local dat = classData[aClass]
    dat.definedVariables[name] = var

    if var == nil then
        for _, parent in ipairs(dat.heirarchyData.parents) do
            if parent[name] ~= nil then
                var = parent
                break
            end
        end
    end

    __propegateClassVariable(aClass, name, var)
end

-- -------------------------------------------------------------------------- --
--                            Inheritance / Mixins                            --
-- -------------------------------------------------------------------------- --

-- Adds a parent to a class
---@param aClass Class
---@param parent Class
local function __addParent(aClass, parent)
    local dat = classData[aClass]
    local parentData = classData[parent]

    table.insert(dat.heirarchyData.parents, parent)
    table.insert(parentData.heirarchyData.children, aClass)

    for key, value in pairs(parentData.definedVariables) do
        if not (key == "__index" and type(f) == "table") then
            __propegateClassVariable(aClass, key, value)
        end
    end
end

-- Checks if the passed object is an instance of a class
---@param self Class object to check
---@param aClass Class class to check against
---@return boolean
local function __is(self, aClass)
    -- If instance, extract class
    if self.class then
        self = self.class
    end

    if self == aClass then
        return true
    end

    local dat = classData[self]
    for _, parent in ipairs(dat.heirarchyData.parents) do
        if __is(parent, aClass) then
            return true
        end
    end

    return false
end

-- Adds a mixin to a class
---@param aClass Class
---@param mixin table
local function __addMixin(aClass, mixin)
    for name, method in pairs(mixin) do
        if name ~= "included" then
            aClass[name] = method
        end
    end

    if type(mixin.included) == "function" then
        mixin:included(aClass)
    end
end

-- -------------------------------------------------------------------------- --
--                               Table Creation                               --
-- -------------------------------------------------------------------------- --

--- Creates an instance of a class
--- @generic T
--- @param aClass T
--- @return T
local function __newInstance(aClass, ...)
    local classDat = classData[aClass]
    local instance = { 
        class = aClass,
        include = __addMixin,
    }

    setmetatable(instance, classDat.lookupDict)

    if instance.__init then
        instance:__init(...)
    end

    return instance
end

--- Creates a new class
--- @param name string
--- @return Class
local function __createClass(name, ...)
    local lookupDict = {}
    lookupDict.__index = lookupDict

    -- Generate class object

    ---@class Class
    local aClass = {
        name = name,
        include = function(self, mixin)
            if type(mixin) ~= "table" then
                error("mixin must be a table")
            end

            if classData[mixin] == nil then
                __addMixin(self, mixin)
            else
                __addParent(self, mixin)
            end
        end,
    }
    -- Setup new method if desired
    if (class_enableNewMethod) then
        aClass.new = __newInstance
    end

    -- Generate internal class data

    classData[aClass] = {
        definedVariables = {},
        lookupDict = lookupDict,
        heirarchyData = {
            children = {},
            parents = {},
        }
    }

    -- Set up metatable for class

    local classMeta = {
        __index = lookupDict,
        __tostring = function()
            return "class(\"" .. name .. "\")"
        end,
        __newindex = function(_, key, value)
            __declareClassVariable(aClass, key, value)
        end
    }
    -- Setup call metamethod if desired
    if (class_enableCallMetamethod) then
        classMeta.__call = __newInstance
    end

    setmetatable(aClass, classMeta)

    -- add "is" method (Added here to ensure its propegated properly)
    aClass.is = __is

    -- Add all mixins
    for _, parent in ipairs({ ... }) do
        aClass:include(parent)
    end

    return aClass
end

-- -------------------------------------------------------------------------- --
--                              LowerClass Setup                              --
-- -------------------------------------------------------------------------- --

--- Generate metatable for lowerclass
local lowerclass_mt = {}
---@diagnostic disable-next-line: param-type-mismatch
setmetatable(lowerclass, lowerclass_mt)

-- Setup call metamethod if desired
if (lowerclass_enableCallMetamethod) then
    lowerclass_mt.__call = function(self, name, ...)
        return __createClass(name, ...)
    end
end

-- Setup new method if desired
if (lowerclass_enableNewMethod) then
    lowerclass.new = function(self, name, ...)
        return __createClass(name, ...)
    end
end

return lowerclass
