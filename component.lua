-- Vendored from dash-xd/lua-simple-components @ 738f9e3c4fed5a45e2b63ce9cfa53bc3b07dfa75
-- Components.lua
-------------------------------------------------------------------------------------------
-- COMPONENTS
-------------------------------------------------------------------------------------------
local componentInstances = setmetatable({}, { __mode = "k" })

local function Component()
	local component = {}
	componentInstances[component] = true
	return component
end

local function isComponent(value)
	return componentInstances[value] == true
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

local Components = setmetatable({}, {
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

return Components, Component
