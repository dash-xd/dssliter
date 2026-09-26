local Component = require(script.Parent.component).Component

local DSSLite = Component()

require(script.Store)
require(script.LazyStores)
require(script.Persistence)
require(script.Cache)

DSSLite.tags = {
	"Store",
	"LazyStores",
	"Persistence",
	"Cache",
}

return DSSLite
