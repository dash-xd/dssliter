local DataStoreService = game:GetService("DataStoreService")
local Component = require(script.Parent.Parent.component).Component

local LazyStores = Component()
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


return LazyStores
