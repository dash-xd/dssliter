local ComponentModule = require(script.Parent.component)
local Components = ComponentModule.Components

Components.Store = require(script.Parent.components.Store)
Components.LazyStores = require(script.Parent.components.LazyStores)
Components.Persistence = require(script.Parent.components.Persistence)
Components.Cache = require(script.Parent.components.Cache)

local function DSSLite()
	return Components:Apply{
		target = {
			_dataStore = nil,
			_cache = nil,
			_entryKey = nil,
		},
		tags = {
			"Store",
			"LazyStores",
			"Persistence",
			"Cache",
		},
	}
end

return DSSLite
