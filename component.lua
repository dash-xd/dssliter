-- Vendored from dash-xd/lua-simple-components @ b277ce97283df21f4f738dff0b27d45a7fff23a3
-- Components.lua
-------------------------------------------------------------------------------------------
-- COMPONENTS
-------------------------------------------------------------------------------------------
local Components
local Component

local ComponentMeta = {
	__index = function(_, key)
		if key == "Components" then
			return Components
	end
	if key == "Component" then
			return Component
	end
end,
}

Component = function()
	return setmetatable({}, ComponentMeta)
end

local function isComponent(value)
	return getmetatable(value) == ComponentMeta
end

-------------------------------------------------------------------------------------------
-- COMPOSITION
-------------------------------------------------------------------------------------------
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

local registered = {}
local RegistryMethods = {}

function RegistryMethods:Apply(args)
	local target = assert(args.target, "Apply requires a target")
	local tags = args.tags or {}
	local parents = args.parents or {}

	for _, tag in ipairs(tags) do
		local component = registered[tag]
		if component then
			table.insert(parents, component)
		else
			warn("Component for tag '" .. tag .. "' not found in Components.")
		end
	end

	setmetatable(target, RegisterParents(parents))
	return target
end

Components = setmetatable({}, {
	__index = function(_, key)
		local method = RegistryMethods[key]
		if method then
			return method
		end
		return registered[key]
	end,

	__newindex = function(_, key, value)
		assert(
			isComponent(value),
			"registered components must be created with Component()"
		)
		registered[key] = value
	end,
})

return {
	Components = Components,
	Component = Component,
}
