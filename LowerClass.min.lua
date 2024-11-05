-- 1788 non-spaced chars :D
local a = {}
local b = setmetatable({}, { __mode = "k" })
local function c(aClass, d) if d == nil then return b[aClass].x[name] elseif type(d) == "function" then return function(
            self, name) return b[aClass].x[name] or d(self, name) end else return function(self, name) return b[aClass]
            .x[name] or d[name] end end end; local function e(aClass, name, d)
    d = name == "__index" and c(aClass, d) or d; b[aClass].x[name] = d; for g, h in ipairs(b[aClass].y.b) do if b[h].z[name] == nil then
            e(h, name, d) end end
end; local function i(aClass, name, d)
    local j = b[aClass]
    j.v[name] = d; if d == nil then for g, k in ipairs(j.y.a) do if k[name] ~= nil then
                d = k; break
            end end end; e(aClass, name, d)
end; local function l(aClass, k)
    table.insert(b[aClass].y.a, k)
    table.insert(b[k].y.b, aClass)
    for m, n in pairs(b[k].v) do if not (m == "__index" and type(f) == "table") then e(aClass, m, n) end end
end; local function o(self, aClass)
    self = self.class or self; if self == aClass then return true end; local j = b[self]
    for g, k in ipairs(j.y.a) do if o(k, aClass) then return true end end; return false
end; local function p(aClass, mixin)
    for name, q in pairs(mixin) do if name ~= "included" then aClass[name] = q end end; if type(mixin.included) == "function" then
        mixin:included(aClass) end
end; local function r(aClass, ...)
    local s = setmetatable({ class = aClass, include = p }, b[aClass].x)
    if s.__init then s:__init(...) end; return s
end; local function t(name, ...)
    local u = {}
    u.__index = u; local aClass = setmetatable(
    { name = name, include = function(self, ...)
        assert(type(mixin) == "table", "mixin must be a table")
        for g, mixin in ipairs({ ... }) do
            local v = b[mixin] == nil and p or l; v(self, mixin)
        end
    end, new = r },
        { __index = u, __tostring = function() return "class(\"" .. name .. "\")" end, __newindex = function(g, m, n) i(
            aClass, m, n) end, __call = r })
    b[aClass] = setmetatable { v = {}, x = u, y = { b = {}, a = {} } }
    aClass.is = o; aClass:include(...)
    return aClass
end; setmetatable(a, { __call = function(self, name, ...) return t(name, ...) end })
a.new = function(self, name, ...) return t(name, ...) end; return a
