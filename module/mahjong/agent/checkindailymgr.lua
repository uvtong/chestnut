local set = require "db.dbset"
local query = require "query"
local cls = class("checkindailymgr", set)

function cls:ctor(env, dbctx, ... )
	-- body
	cls.super.ctor(self, env, dbctx)
	self._tname = "tu_checkindaily"
	return self
end

function cls:dtor( ... )
	-- body
end

return cls