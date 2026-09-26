local Store = require(script.Parent.components.Store)
require(script.Parent.components.LazyStores)
require(script.Parent.components.Persistence)
require(script.Parent.components.Cache)

local Components = Store.Components

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
