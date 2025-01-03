local a = {}
local b = setmetatable({}, { __mode = "k" })
local function c(d, e) if e == nil then return b[d].lookupDict elseif type(e) == "function" then return function(
            self, name) return e(self, name) or b[d].lookupDict[name] end else return function(self, name) return e
            [name] or b[d].lookupDict[name] end end end; local function g(d, name, e)
    e = name == "__index" and c(d, e) or e; b[d].lookupDict[name] = e; for h, i in ipairs(b[d].heirarchyData.children) do if b[i].definedVariables[name] == nil then
            g(i, name, e) end end
end; local function j(d, name, e)
    local k = b[d]
    k.definedVariables[name] = e; if e == nil then for h, l in ipairs(k.heirarchyData.parents) do if l[name] ~= nil then
                e = l; break
            end end end; g(d, name, e)
end; local function m(d, l)
    table.insert(b[d].heirarchyData.parents, l)
    table.insert(b[l].heirarchyData.children, d)
    for n, o in pairs(b[l].definedVariables) do if not (n == "__index" and type(o) == "table") then g(d, n, o) end end
end; local function p(self, d)
    self = self.class or self; if self == d then return true end; local k = b[self]
    for h, l in ipairs(k.heirarchyData.parents) do if p(l, d) then return true end end; return false
end; local function q(d, r)
    for name, s in pairs(r) do if name ~= "included" then d[name] = s end end; if type(r.included) == "function" then r
            :included(d) end
end; local function t(d, ...)
    local u = setmetatable({ __type = d.name, class = d, include = q }, b[d].lookupDict)
    if u.__init then u:__init(...) end; return u
end; local function v(name, ...)
    local w = {}
    w.__index = w; local d = setmetatable(
    { __type = "class", name = name, include = function(self, ...) for h, r in ipairs({ ... }) do
            if type(r) == "function" then r = r(self) end; assert(type(r) == "table", "mixin must be a table")
            local x = b[r] == nil and q or m; x(self, r)
        end end, new = t }, { __index = w, __tostring = function() return "class(\"" .. name .. "\")" end, __newindex = j, __call =
    t })
    b[d] = { definedVariables = {}, lookupDict = w, heirarchyData = { children = {}, parents = {} } }
    d.is = p; d:include(...)
    return d
end; setmetatable(a, { __call = function(self, name, ...) return v(name, ...) end })
a.new = function(self, name, ...) return v(name, ...) end; local y = type; a.type = function(z) return y(z) == "table" and
    z.__type or y(z) end; return a
