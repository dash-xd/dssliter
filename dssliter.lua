local DSSLiteComponent = require(script.Parent.components)

local function DSSLite()
	return DSSLiteComponent.Components:Apply{
		target = {},
		tags = DSSLiteComponent.tags,
	}
end

return DSSLite
