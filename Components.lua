-- Vendored from dash-xd/lua-simple-components @ 4bcc916ae60e4d2d64738dcc08111f9ef7a63578
-- Components.lua
-------------------------------------------------------------------------------------------
-- COMPOSITION
-------------------------------------------------------------------------------------------
local GlobalComponents
local Component

local RegistryMethods = {}

local function searchParents(key, parents)
	for i = 1, #parents do
		local found = parents[i][key]
		if found then
			return found
		end
	end
end

local function RegisterParents(parents)
	return {
		__index = function(_, key)
			return searchParents(key, parents)
		end
	}
end

function RegistryMethods:Apply(args)
	local target = assert(args.target, "Apply requires a target")
	local tags = args.tags or {}
	local parents = args.parents or {}

	for _, tag in ipairs(tags) do
		local component = self[tag]
		if component then
			table.insert(parents, component)
		else
			warn("Component for tag '" .. tag .. "' not found in Components.")
		end
	end

	setmetatable(target, RegisterParents(parents))
	return target
end

local function newRegistry()
	local registry = {}

	return setmetatable(registry, {
		__index = function(_, key)
			if key == "Components" then
				return GlobalComponents
			end
			if key == "Component" then
				return Component
			end
			return RegistryMethods[key]
		end,
	})
end

Component = function()
	return newRegistry()
end

GlobalComponents = newRegistry()

return GlobalComponents, Component
