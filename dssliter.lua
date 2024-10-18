local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

local StoreLazyLoader = {}
local function initLazyLoader()
	local stores = {};
	function StoreLazyLoader:Add(key, store)
		if not store then
			store = DataStoreService:GetDataStore(key)
		end
		stores[key] = store
		print("store lazy loaded ... current stores: ")
		print(stores);
		return stores[key]
	end
	
	function StoreLazyLoader:Get(key)
		return stores[key]
	end

	function StoreLazyLoader:Remove(key)
		stores[key] = nil
	end
	
	function StoreLazyLoader:RemoveAll(key)
		stores = {}
	end
end

initLazyLoader();

-- DataStoreServiceLite (DSSLite)
local function DSSLite()
	local dsmod = {}
	local DataStore = nil
	local cache = nil
	local entryKey = nil

	function dsmod.CopyTable(t)
		local success, result = pcall(function()
			return HttpService:JSONDecode(HttpService:JSONEncode(t))
		end)
		if not success then
			warn("Failed to deep copy table: " .. tostring(result))
			return nil  -- Return nil if the copy fails
		end
		return result
	end

	function dsmod.InitStore(key)
		print("Initializing store: " .. key)
		if not DataStore then
			DataStore = StoreLazyLoader:Add(key);
			return true
		end
		print("use DSSLite:ReleaseStore() before running DSSLite:InitStore(key) again")
		return false
	end
	
	function dsmod.SetStore(datastore) -- does not use lazyloader
		DataStore = datastore;
		return;
	end

	function dsmod.GetStore()
		return DataStore
	end

	function dsmod.ReleaseStore()
		if DataStore then
			DataStore = nil
			return true
		end
		print("There is no DataStore to release")
		return false
	end

	-------------------------------------------------------
	function dsmod.GetData(key)
		local success, result = pcall(function()
			return DataStore:GetAsync(key)
		end)
		if not success then
			warn(result)
		end
		return success, result
	end

	function dsmod:GetCacheCopy()
		-- Return the value directly if it's not a table or a reference
		if type(cache) ~= "table" then
			return cache
		end
		-- If it is a table, perform a deep copy
		return self.CopyTable(cache)
	end

	function dsmod.LoadIntoCache(key)
		print("loading data into cache")
		entryKey = key
		local success = nil;
		success, cache = dsmod.GetData(key)
		print("did system load cache: " .. tostring(success))
		return success;
	end

	function dsmod.SaveData(key, data)
		local success, result = pcall(function()
			DataStore:SetAsync(key, data)
		end)
		if not success then
			warn(result)
		end
		return success, result 
	end

	function dsmod.ReleaseCache()
		cache = nil
		entryKey = nil
		return true
	end

	function dsmod:SaveCache()
		return self:SaveData(entryKey, cache)
	end

	function dsmod:SaveAndReleaseCache()
		self:SaveCache()
		self:ReleaseCache()
	end

	function dsmod:SaveCacheAndReleaseFull()
		self:SaveAndReleaseCache()
		self:ReleaseStore()
	end
	-------------------------------------------------------------

	function dsmod.UpdateCache(newData, ...) -- variadic args are any number of nested keys
		-- If cache is not a table, directly update it
		if type(cache) ~= "table" then
			cache = newData
			print("Cache updated directly to: " .. tostring(newData))
			return true
		end

		local function update(t, newData, ...)
			print("searching for key " .. (...) .. " in: ")
			print(t)
			if type(t) == "table" then
				if t[(...)] then
					print((...) .. " is found in cache")
					print(select('#', ...))
					if select('#', ...) == 1 then
						print("reached end, updating value for key: " .. ((...)))
						t[(...)] = newData
						return true
					else
						return update(t[(...)], newData, select(2, ...))
					end
				else
					return false
				end
			end
			return false
		end

		return update(cache, newData, ...)
	end
	
	-------------------------------------------------------------

	function dsmod.GetCachedStore(key)
		return StoreLazyLoader:Get(key)
	end

	return dsmod
end

return DSSLite
