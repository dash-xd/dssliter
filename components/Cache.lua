local HttpService = game:GetService("HttpService")
local Component = require(script.Parent.Parent.component).Component

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

return Cache
