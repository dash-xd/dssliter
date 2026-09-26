local Component = require(script.Parent.Parent.component).Component

local Persistence = Component()

function Persistence:GetData(key)
	local success, result = pcall(function()
		return self._dataStore:GetAsync(key)
	end)
	if not success then
		warn(result)
	end
	return success, result
end

function Persistence:SaveData(key, data)
	local success, result = pcall(function()
		self._dataStore:SetAsync(key, data)
	end)
	if not success then
		warn(result)
	end
	return success, result
end

Persistence.Components.Persistence = Persistence

return Persistence
