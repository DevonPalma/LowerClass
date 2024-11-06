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
            return var(self, name) or classData[aClass].lookupDict[name]
        end
    else -- if  type(f) == "table" then
        return function(self, name)
            return var[name] or classData[aClass].lookupDict[name]
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
    table.insert(classData[aClass].heirarchyData.parents, parent)
    table.insert(classData[parent].heirarchyData.children, aClass)

    for key, value in pairs(classData[parent].definedVariables) do
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
    ---@diagnostic disable-next-line: undefined-field
    self = self.class or self

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
    local instance = setmetatable({
        __type = aClass.name,
        class = aClass,
        include = __addMixin,
    }, classData[aClass].lookupDict)

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
    local aClass = setmetatable({
        __type = "class",
        name = name,
        include = function(self, ...)
            -- If mixin is not registered as a class, use addMixin, otherwise use addParent
            for _, mixin in ipairs({ ... }) do
                if type(mixin) == "function" then
                    mixin = mixin(self)
                end
                assert(type(mixin) == "table", "mixin must be a table")
                local func = classData[mixin] == nil and __addMixin or __addParent
                func(self, mixin)
            end
        end,
        new = __newInstance,
    }, {
        __index = lookupDict,
        __tostring = function()
            return "class(\"" .. name .. "\")"
        end,
        __newindex = __declareClassVariable,
        __call = __newInstance
    })

    -- Generate internal class data

    classData[aClass] = {
        definedVariables = {},
        lookupDict = lookupDict,
        heirarchyData = {
            children = {},
            parents = {},
        }
    }

    -- Finalize setup by adding `is` method and all mixins
    aClass.is = __is
    aClass:include(...)

    return aClass
end

-- -------------------------------------------------------------------------- --
--                              LowerClass Setup                              --
-- -------------------------------------------------------------------------- --

---@diagnostic disable-next-line: param-type-mismatch
setmetatable(lowerclass, {
    __call = function(self, name, ...)
        return __createClass(name, ...)
    end,
})

-- Setup new method
lowerclass.new = function(self, name, ...)
    return __createClass(name, ...)
end

lowerclass.type = function(obj)
    return type(obj) == "table" and obj.__type or type(obj)
end

return lowerclass
