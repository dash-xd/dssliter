local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

local Components, Component = require(script.Parent.Components)

local stores = {}

local function deepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

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

local LazyStores = Component()

function LazyStores:GetCachedStore(key)
	return stores[tostring(key)]
end

function LazyStores:LazyLoadStore(key)
	key = tostring(key)
	if not stores[key] then
		stores[key] = DataStoreService:GetDataStore(key)
		print("store lazy loaded ... current stores: ")
		print(stores)
	end
	return stores[key]
end

function LazyStores:RemoveCachedStore(key)
	stores[tostring(key)] = nil
end

function LazyStores:RemoveAllCachedStores()
	stores = {}
end

function LazyStores:GetCachedStores()
	return deepCopy(stores)
end

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

local Cache = Component()

local function copyTable(value)
	local success, result = pcall(function()
		return HttpService:JSONDecode(HttpService:JSONEncode(value))
	end)
	if not success then
		warn("Failed to deep copy table: " .. tostring(result))
		return nil
	end
	return result
end

function Cache:GetCacheCopy()
	if type(self._cache) ~= "table" then
		return self._cache
	end
	return copyTable(self._cache)
end

function Cache:LoadIntoCache(key)
	print("loading key into cache: " .. tostring(key))
	self._entryKey = key
	local success
	success, self._cache = self:GetData(key)
	print("did system load cache value: " .. tostring(success))
	return success
end

function Cache:ReleaseCache()
	self._cache = nil
	self._entryKey = nil
	return true
end

function Cache:SaveCache()
	return self:SaveData(self._entryKey, self._cache)
end

function Cache:SaveCacheToEntry(key)
	return self:SaveData(key, self._cache)
end

function Cache:SaveAndReleaseCache()
	self:SaveCache()
	self:ReleaseCache()
end

function Cache:SaveCacheAndReleaseFull()
	self:SaveAndReleaseCache()
	self:ReleaseStore()
end

function Cache:UpdateCache(newData, ...)
	if type(self._cache) ~= "table" then
		self._cache = newData
		print("Cache updated directly to: " .. tostring(newData))
		return true
	end

	local function update(t, value, ...)
		print("searching for key " .. tostring((...)) .. " in: ")
		print(t)
		if type(t) ~= "table" then
			return false
		end
		if t[(...)] == nil then
			return false
		end
		if select("#", ...) == 1 then
			t[(...)] = value
			return true
		end
		return update(t[(...)], value, select(2, ...))
	end

	return update(self._cache, newData, ...)
end

Components.Store = Store
Components.LazyStores = LazyStores
Components.Persistence = Persistence
Components.Cache = Cache

local function DSSLite()
	return Components:Apply{
		target = {},
		tags = {
			"Store",
			"LazyStores",
			"Persistence",
			"Cache",
		},
	}
end

return DSSLite
