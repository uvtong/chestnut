local u_wallet_set = require "u_wallet_set"
local dbcontext = require "dbcontext"
local cls = class("host_dbcontext", dbcontext)

function cls:ctor(env, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, rdb, wdb)
	self._uw
	return self
end

function cls:load( ... )
	-- body
end

return cls