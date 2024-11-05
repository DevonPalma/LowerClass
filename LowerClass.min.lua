local a = true; local b = true; local c = true; local d = true; local e = {}
local g = setmetatable({}, { __mode = "k" })
local function h(i, j) if j == nil then return g[i].lookupDict[name] elseif type(j) == "function" then return function(
            self, name) return g[i].lookupDict[name] or j(self, name) end else return function(self, name) return g[i]
            .lookupDict[name] or j[name] end end end; local function k(i, name, j)
    j = name == "__index" and h(i, j) or j; g[i].lookupDict[name] = j; for l, m in ipairs(g[i].heirarchyData.children) do if g[m].definedVariables[name] == nil then
            k(m, name, j) end end
end; local function n(i, name, j)
    local o = g[i]
    o.definedVariables[name] = j; if j == nil then for l, p in ipairs(o.heirarchyData.parents) do if p[name] ~= nil then
                j = p; break
            end end end; k(i, name, j)
end; local function q(i, p)
    local o = g[i]
    local r = g[p]
    table.insert(o.heirarchyData.parents, p)
    table.insert(r.heirarchyData.children, i)
    for s, t in pairs(r.definedVariables) do if not (s == "__index" and type(f) == "table") then k(i, s, t) end end
end; local function u(self, i)
    if self.class then self = self.class end; if self == i then return true end; local o = g[self]
    for l, p in ipairs(o.heirarchyData.parents) do if u(p, i) then return true end end; return false
end; local function v(i, w)
    for name, x in pairs(w) do if name ~= "included" then i[name] = x end end; if type(w.included) == "function" then w
            :included(i) end
end; local function y(i, ...)
    local z = g[i]
    local A = { class = i, include = v }
    setmetatable(A, z.lookupDict)
    if A.__init then A:__init(...) end; return A
end; local function B(name, ...)
    local C = {}
    C.__index = C; local i = { name = name, include = function(self, w)
        if type(w) ~= "table" then error("mixin must be a table") end; if g[w] == nil then v(self, w) else q(self, w) end
    end }
    if d then i.new = y end; g[i] = { definedVariables = {}, lookupDict = C, heirarchyData = { children = {}, parents = {} } }
    local D = { __index = C, __tostring = function() return "class(\"" .. name .. "\")" end, __newindex = function(l, s,
                                                                                                                   t) n(
        i, s, t) end }
    if c then D.__call = y end; setmetatable(i, D)
    i.is = u; for l, p in ipairs({ ... }) do i:include(p) end; return i
end; local E = {}
setmetatable(e, E)
if a then E.__call = function(self, name, ...) return B(name, ...) end end; if b then e.new = function(self, name, ...) return
        B(name, ...) end end; return e
