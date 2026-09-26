local ComponentModule = require(script.Parent.Parent.component)
local Components = ComponentModule.Components
local Component = ComponentModule.Component

local Store = Component()

function Store:InitStore(key)
	print("Initializing store: " .. key)
	if not self._dataStore then
		self._dataStore = self:LazyLoadStore(key)
		return true
	end
	print("use DSSLite:ReleaseStore() before running DSSLite:InitStore(key) again")
	return false
end

function Store:SetStore(datastore)
	self._dataStore = datastore
end

function Store:GetStore()
	return self._dataStore
end

function Store:ReleaseStore()
	if self._dataStore then
		self._dataStore = nil
		return true
	end
	print("There is no DataStore to release")
	return false
end

Store.Components.Store = Store

return Store
