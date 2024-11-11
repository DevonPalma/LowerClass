-- TreeMixin.lua
-- A mixin to add tree structure functionality to a class

---@class TreeMixin
---@field parent any
---@field children any[]
local TreeMixin = {
	-- Sets the parent of the current object
	setParent = function(self, parent)
		self.parent = parent
		if not parent.children then
			parent.children = {}
		end
		table.insert(parent.children, self)
	end,

	-- Adds a child to the current object
	addChild = function(self, child, index)
		index = index or #self.children + 1
		self.children = self.children or {}
		table.insert(self.children, index, child)
		child.parent = self
	end,

	-- Removes a child from the current object
	removeChild = function(self, child)
		if not self.children then return end
		for i, c in ipairs(self.children) do
			if c == child then
				table.remove(self.children, i)
				child.parent = nil
				break
			end
		end
	end,

	-- Retrieves all descendants of the current object
	getDescendants = function(self)
		local descendants = {}
		local function gatherDescendants(node)
			if node.children then
				for _, child in ipairs(node.children) do
					table.insert(descendants, child)
					gatherDescendants(child)
				end
			end
		end
		gatherDescendants(self)
		return descendants
	end,

	-- Retrieves all ancestors of the current object
	getAncestors = function(self)
		local ancestors = {}
		local node = self.parent
		while node do
			table.insert(ancestors, node)
			node = node.parent
		end
		return ancestors
	end,

	-- Checks if the current object is a descendant of another node
	isDescendantOf = function(self, node)
		local ancestor = self.parent
		while ancestor do
			if ancestor == node then
				return true
			end
			ancestor = ancestor.parent
		end
		return false
	end,

	-- Checks if the current object is an ancestor of another node
	isAncestorOf = function(self, node)
		return node:isDescendantOf(self)
	end
}

return TreeMixin
